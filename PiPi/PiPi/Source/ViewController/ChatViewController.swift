//
//  ChatViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/27.
//

import UIKit
import RxSwift
import RxCocoa

class ChatViewController: UIViewController {

    @IBOutlet weak var textInputView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var keyboardShown:Bool = false // 키보드 상태 확인
    var originY:CGFloat? // 오브젝트의 기본 위치
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        setupUI()
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
    @IBOutlet weak var timeLabel: UILabel!
}

class YourChatCell: UITableViewCell {
    @IBOutlet weak var yourNameLabel: UILabel!
    @IBOutlet weak var yourMessageLabel: UILabel!
    @IBOutlet weak var yourImageView: UIImageView!
}

extension ChatViewController: UITableViewDelegate
{
    //Transparent Cell Background
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}
 
extension ChatViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let myCell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! MyChatCell
//
//        myCell.myMessageLabel.text = "내용입니다. 내용입니다. 내용입니다. 내용입니다. 내용입니다. 내용입니다. 내용입니다. 내용입니다. 내용입니다. 내용입니다. "
//        myCell.timeLabel.text = "오후 6:30"
        
        let youCell = tableView.dequeueReusableCell(withIdentifier: "youCell") as! YourChatCell
        
        youCell.yourImageView.image = UIImage(named: "")
        youCell.yourMessageLabel.text = "내용입니다."
        youCell.yourNameLabel.text = "ㅇㅅㅇ"
        
        circleOfImageView(youCell.yourImageView)
        
        return youCell
    }
}

enum CellType {
    case YourMessages
    case MyMessages
}
