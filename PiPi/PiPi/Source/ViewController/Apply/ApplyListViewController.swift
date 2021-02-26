//
//  ApplyListViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/04.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ApplyListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createProjectBtn: UIButton!
    
    private let viewModel = ApplyListViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private var selectApply = BehaviorRelay<Int>(value: 0)
    private let access = BehaviorRelay<Void>(value: ())
    private let reject = BehaviorRelay<Void>(value: ())
    private let goToChat = BehaviorRelay<Int>(value: 0)
    private var index = Int()
    
    var selectIndexPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        registerCell()
    }
    
    func bindViewModel() {
        let input = ApplyListViewModel.input(
            loadApplyData: loadData.asSignal(onErrorJustReturn: ()),
            selectApplyList: selectIndexPath,
            selectIndexPath: selectApply.asSignal(onErrorJustReturn: 0),
            selectAccept: access.asSignal(onErrorJustReturn: ()),
            selectReject: reject.asSignal(onErrorJustReturn: ()),
            createProject: createProjectBtn.rx.tap.asDriver(),
            goToChat: goToChat.asSignal(onErrorJustReturn: 0))
        let output = viewModel.transform(input)
        
        ApplyListViewModel.loadApplyList
            .bind(to: tableView.rx.items(cellIdentifier: "applylistCell", cellType: ListTableViewCell.self)) {[unowned self] (row, item, cell) in
                cell.configCell(item)
                
                cell.accessBtn.rx.tap.subscribe(onNext: {[unowned self] _ in selectApply.accept(row) }).disposed(by: cell.disposeBag)
                cell.rejectBtn.rx.tap.subscribe(onNext: {[unowned self] _ in selectApply.accept(row) }).disposed(by: cell.disposeBag)
                cell.chatBtn.rx.tap.subscribe(onNext: {[unowned self] _ in goToChat.accept(row) }).disposed(by: cell.disposeBag)
                
                setButton(cell.chatBtn, false)
                setListBtn(cell.accessBtn, cell.rejectBtn, item.status)
            }.disposed(by: rx.disposeBag)
        
        Observable.of(output.accept, output.reject).merge().subscribe(onNext: {[unowned self] _ in
            loadData.accept(())
            tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.create.emit(onNext: {[unowned self] message in
            showAlert(title: "실패", message: message)
        },onCompleted: {[unowned self] in
            navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        output.goChat.emit(onNext: {[unowned self] id in
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
            vc.roomId = id
            navigationController!.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func registerCell() {
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "applylistCell")
        tableView.rowHeight = 72
    }
}
