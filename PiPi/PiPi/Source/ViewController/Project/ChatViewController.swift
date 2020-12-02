//
//  ChatViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/27.
//

import UIKit
import RxSwift
import RxCocoa
import SocketIO
import Kingfisher

class ChatViewController: UIViewController {

    @IBOutlet weak var textInputView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private let getEmail = BehaviorRelay<Void>(value: ())
    private let viewModel = ChatViewModel()
    private let loadChat = BehaviorRelay<Void>(value: ())
    
    var keyboardShown:Bool = false // 키보드 상태 확인
    var originY:CGFloat? // 오브젝트의 기본 위치
    var socket: SocketIOManager!
    var socketClient: SocketIOClient!
    var email = String()
    var roomId = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.socketClient = SocketIOManager.shared.socket
        
        SocketIOManager.shared.establishConnection()
        SocketIOManager.shared.socket.emit("join", roomId)

        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        tableView.separatorStyle = .none
        messageTextfield.backgroundColor = .white
        textInputView.backgroundColor = UIColor().hexUIColor(hex: "DBDBDB")
        setButton(sendBtn)
        
        messageTextfield.rx.text.orEmpty.subscribe(onNext: { _ in
            self.addKeyboardNotification()
        }).disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        let input = ChatViewModel.input(
            showEmail: getEmail.asSignal(onErrorJustReturn: ()),
            loadChat: loadChat.asSignal(onErrorJustReturn: ()),
            roomId: roomId)
        let output = viewModel.transform(input)
        
        output.loadChat.asObservable().bind(to: tableView.rx.items) { tableview, row, item -> UITableViewCell in
            if item.mine {
                let cell: MyChatCell = self.tableView.dequeueReusableCell(withIdentifier: "myCell") as! MyChatCell
                
                cell.myMessageLabel.text = item.message
                
                return cell
            }else {
                let cell: YourChatCell = self.tableView.dequeueReusableCell(withIdentifier: "youCell") as! YourChatCell
                
                cell.yourImageView.layer.cornerRadius = 28
                cell.yourNameLabel.text = item.userNickname
                cell.yourMessageLabel.text = item.message
                cell.yourNameLabel.text = item.userNickname
                cell.yourImageView.kf.setImage(with: URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(item.profileImg)"))
                
                return cell
            }
        }.disposed(by: rx.disposeBag)
        
        sendBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            self.socketClient.emit("chat", ["roomId": roomId, "userEmail": email, "message": messageTextfield.text ?? ""])
            
            let new = getChat(userNickname: email, message: messageTextfield.text!, mine: true, profileImg: "")
            
            output.loadChat.add(element: new)
            messageTextfield.text = ""
        }).disposed(by: rx.disposeBag)
        
        socketClient.on("receive") { (data, ack) in
            let name = data[2] as! String
            let message = data[3] as! String
            let profileImg = data[1] as! String
    
            let chat = getChat(userNickname: name, message: message, mine: false, profileImg: profileImg)
            
            output.loadChat.add(element: chat)
        }
        
        output.result.emit(onNext: { email in
            self.email = email
        }).disposed(by: rx.disposeBag)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height == 0.0 || keyboardShown == true {
                return
            }
            
            UIView.animate(withDuration: 0.33, animations: {[unowned self] () -> Void in
                if originY == nil { originY = textInputView.frame.origin.y }
                textInputView.frame.origin.y = originY! - keyboardSize.height + messageTextfield.frame.height
            }, completion: {_ in
                self.keyboardShown = true
            })
        }
    }
    
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardShown == false {
                return
            }
            
            UIView.animate(withDuration: 0.33, animations: {[unowned self] () -> Void in
                guard let originY = originY else { return }
                textInputView.frame.origin.y = originY
            }, completion: {_ in
                self.keyboardShown = false
            })
        }
        
    }
}



class MyChatCell: UITableViewCell {
    @IBOutlet weak var myMessageLabel: UILabel!
}

class YourChatCell: UITableViewCell {
    @IBOutlet weak var yourNameLabel: UILabel!
    @IBOutlet weak var yourMessageLabel: UILabel!
    @IBOutlet weak var yourImageView: UIImageView!
}

enum CellType {
    case YourMessages
    case MyMessages
}

extension BehaviorRelay where Element: RangeReplaceableCollection {
    func add(element: Element.Element) {
        var array = self.value
        array.append(element)
        self.accept(array)
    }
}
