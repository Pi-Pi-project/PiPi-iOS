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
    
    private let viewModel = ApplyListViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private let access = BehaviorRelay<Void>(value: ())
    private let reject = BehaviorRelay<Void>(value: ())
    private var index = Int()
    var selectIndexPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("select \(selectIndexPath)")
        bindViewModel()
        registerCell()
    }
    
    func bindViewModel() {
        let input = ApplyListViewModel.input(
            loadApplyData: loadData.asSignal(onErrorJustReturn: ()),
            selectApplyList: selectIndexPath,
            selectIndexPath: Signal.just(index),
            selectAccept: access.asSignal(onErrorJustReturn: ()),
            selectReject: reject.asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input)
        
        ApplyListViewModel.loadApplyList
            .bind(to: tableView.rx.items(cellIdentifier: "applylistCell", cellType: ListTableViewCell.self)) { (row, repository, cell) in
                
                let url = URL(string: "http://10.156.145.141:8080/image/\(repository.userImg)/")
                cell.userImageView.kf.setImage(with: url)
                cell.userName.text = repository.userNickname
                self.setListBtn(cell.accessBtn, cell.rejectBtn, repository.status)
                self.setButton(cell.chatBtn, false)
                cell.index = row
            }.disposed(by: rx.disposeBag)
    }
    
    func registerCell() {
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "applylistCell")
        
        tableView.rowHeight = 72
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
