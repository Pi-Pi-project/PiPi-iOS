//
//  ChatListViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/26.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ChatListViewController: UIViewController {

    @IBOutlet weak var chatListTableView: UITableView!
    
    private let viewModel = ChatListViewModel()
    private let loadList = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel() {
        let input = ChatListViewModel.input(
            loadList: loadList.asSignal(onErrorJustReturn: ()),
            selectIndexPath: chatListTableView.rx.itemSelected.asSignal())
        let output = viewModel.transform(input)
        
        output.loadList.bind(to: chatListTableView.rx.items(cellIdentifier: "listCell", cellType: UITableViewCell.self)) { row, item, cell in
            print(item)
            let coverImg = "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(item.coverImg ?? "")"
            cell.textLabel?.text = item.title
        }.disposed(by: rx.disposeBag)
        
        output.room.emit(onNext: { id in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as? ChatViewController else { return }
            vc.roomId = id
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        
        chatListTableView.rowHeight = 60
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
