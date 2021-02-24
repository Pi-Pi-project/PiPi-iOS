//
//  ApplyViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/03.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Kingfisher
import iOSDropDown

class ApplyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = ApplyViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private let loadMoreData = PublishSubject<Int>()
    
    var count: Int = 0
    
    lazy var floatingButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
        button.addTarget(self, action: #selector(floatingBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "post.png"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        bindViewModel()
        registerCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let view = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
            view.addSubview(floatingButton)
            setupUI()
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let view = UIApplication.shared.windows.filter({$0.isKeyWindow}).first, floatingButton.isDescendant(of: view) {
            floatingButton.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func registerCell() {
        let nib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "joinCell")
        
        tableView.rx.didScroll.asObservable().subscribe(onNext: {[unowned self] _ in
            if tableView.contentOffset.y > tableView.contentSize.height - tableView.bounds.size.height {
                loadMoreData.onNext(count)
                count += 1
                tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        
        tableView.rowHeight = 200
    }
    
    func bindViewModel() {
        let input = ApplyViewModel.input(
            loadData: loadData.asSignal(onErrorJustReturn: ()),
            selectApplyRow: tableView.rx.itemSelected.asSignal(),
            loadMoreData: loadMoreData.asSignal(onErrorJustReturn: 0))
        let output = viewModel.transform(input)
        
        ApplyViewModel.loadApplyData
            .bind(to: tableView.rx.items(cellIdentifier: "joinCell", cellType: MainTableViewCell.self)) { (row, repository, cell) in
                var skillSet = String()
                let backimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(repository.img ?? "")")
                let userimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(repository.userImg ?? "")")
                
                for i in 0..<repository.postSkillsets.count {
                    skillSet = " " + repository.postSkillsets[i].skill + " "
                }
                
                cell.backImageView.kf.setImage(with: backimg)
                cell.projectLabel.text = repository.title
                cell.skilsLabel.text = skillSet
                cell.userImgView.kf.setImage(with: userimg)
            }.disposed(by: rx.disposeBag)
        
        output.loadMoreData.subscribe(onNext:{[unowned self] data in
            for i in 0..<data.count {
                ApplyViewModel.loadApplyData.add(element: data[i])
            }
            tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.detailView.asObservable().subscribe(onNext: {[unowned self] id in
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
            vc.selectIndexPath = id
            navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onCompleted : {[unowned self] in tableView.reloadData() }).disposed(by: rx.disposeBag)
    }
    
    func setupUI(){
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            floatingButton.heightAnchor.constraint(equalToConstant: 80),
            floatingButton.widthAnchor.constraint(equalToConstant: 80)
        ])
        floatingButton.layer.cornerRadius = 40
        floatingButton.layer.masksToBounds = true
        floatingButton.layer.borderColor = UIColor.clear.cgColor
        floatingButton.layer.borderWidth = 4
    }
    
    @objc func floatingBtn(){
        let pushVC = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! PostViewController
        present(pushVC, animated: true, completion: nil)
    }
}
