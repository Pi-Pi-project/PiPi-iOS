//
//  MyPostViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/03.
//

import UIKit
import RxSwift
import RxCocoa
import iOSDropDown

class MyPostViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: DropDown!
    @IBOutlet weak var searchBtn: UIButton!
    
    private let viewModel = MyPostViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private var selectIndexPath = BehaviorRelay<Int>(value: 0)
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
        self.navigationController?.isNavigationBarHidden = false

        bindViewModel()
        registerCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let view = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
            view.addSubview(floatingButton)
            setupUI()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let view = UIApplication.shared.windows.filter({$0.isKeyWindow}).first, floatingButton.isDescendant(of: view) {
            floatingButton.removeFromSuperview()
        }
    }
    
    func registerCell() {
        let nib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "joinCell")
        
        tableView.rx.didScroll.asObservable().subscribe(onNext: { _ in
            if self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.bounds.size.height {
                self.loadMoreData.onNext(self.count)
                self.count += 1
                self.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        
        tableView.rowHeight = 200
    }
    
    func bindViewModel() {
        let input = MyPostViewModel.input(
            loadMyPost: loadData.asSignal(onErrorJustReturn: ()),
            selectMyPostRow: selectIndexPath.asSignal(onErrorJustReturn: 0), loadMoreData: loadMoreData.asSignal(onErrorJustReturn: 0))
        let output = viewModel.transform(input)
        
        MyPostViewModel.loadMyPost
            .bind(to: tableView.rx.items(cellIdentifier: "joinCell", cellType: MainTableViewCell.self)) { (row, repository, cell) in
                var skillSet = String()
                
                for i in 0..<repository.postSkillsets.count {
                    skillSet.append(" " + repository.postSkillsets[i].skill + " ")
                }
                
                let backimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(repository.img ?? "")")
                cell.backImageView.kf.setImage(with: backimg)
                cell.projectLabel.text = repository.title
                cell.skilsLabel.text = skillSet
                cell.userImgView.isHidden = true
                cell.applyListBtn.isHidden = false
                cell.applyListBtn.rx.tap.subscribe(onNext: { _ in
                    self.selectIndexPath.accept(row)
                }).disposed(by: self.rx.disposeBag)
            }.disposed(by: rx.disposeBag)

        output.loadMoreData.subscribe(onNext:{ data in
            for i in 0..<data.count {
                MyPostViewModel.loadMyPost.add(element: data[i])
            }
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.detailView.asObservable().subscribe(onNext: { id in
            print("Asf")
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "applylistVC") as? ApplyListViewController else { return }
            vc.selectIndexPath = id
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
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
