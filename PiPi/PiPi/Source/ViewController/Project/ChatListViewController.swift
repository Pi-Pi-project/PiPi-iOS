//
//  ChatListViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/26.
//

import UIKit
import RxSwift
import RxCocoa

class ChatListViewController: UIViewController {

    @IBOutlet weak var chatListTableView: UITableView!
    
    private let viewModel = ChatListViewModel()
    private let loadList = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        navigationController?.isNavigationBarHidden = true
        chatListTableView.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    func bindViewModel() {
        let input = ChatListViewModel.input(
            loadList: loadList.asSignal(onErrorJustReturn: ()),
            selectIndexPath: chatListTableView.rx.itemSelected.asSignal())
        let output = viewModel.transform(input)
        
        output.loadList.bind(to: chatListTableView.rx.items(cellIdentifier: "listCell", cellType: UITableViewCell.self)) { row, item, cell in
            cell.textLabel?.text = item.title
        }.disposed(by: rx.disposeBag)
        
        output.room.emit(onNext: {[unowned self] id in
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "chatVC") as? ChatViewController else { return }
            vc.roomId = id
            navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        
        chatListTableView.rowHeight = 60
    }

}
