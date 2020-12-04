//
//  JoinViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import iOSDropDown

class JoinViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: DropDown!
    @IBOutlet weak var searchBtn: UIButton!
    
    private let viewModel = MainViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private let selectSearch = PublishRelay<String>()
    private let loadMoreData = PublishSubject<Int>()
    private let loadMoreSearch = PublishSubject<Int>()
    
    var check = Bool()
    var count: Int = 0
    
    lazy var floatingButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
        button.addTarget(self, action: #selector(floatingBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "post.png"), for: .normal)
        return button
    }()
    
    let category = ["Web", "MoblieApp", "DataScience", "System", "Network", "MachineLearning", "Security", "Embedded", "VR", "Game" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
 
        searchBar.placeholder = "카테고리로 검색하기"
        searchBar.optionArray = category
        searchBar.selectedRowColor = UIColor().hexUIColor(hex: "61BFAD")
    
        searchBtn.rx.tap.subscribe(onNext: { _ in
            self.selectSearch.accept(self.category[self.searchBar.selectedIndex ?? 0])
            self.check = true
            self.count = 0
        }).disposed(by: rx.disposeBag)
        
        bindViewModel()
        registerCell()
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let view = UIApplication.shared.windows.filter({$0.isKeyWindow}
        ).first{
            view.addSubview(floatingButton)
            setupUI()
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
                if self.check {
                    self.loadMoreSearch.onNext(self.count)
                    self.count += 1
                }else {
                    self.loadMoreData.onNext(self.count)
                    self.count += 1
                    self.tableView.reloadData()
                }
            }
        }).disposed(by: rx.disposeBag)
        
        tableView.rowHeight = 200
    }
    
    func bindViewModel() {
        let input = MainViewModel.input(
            loadData: loadData.asSignal(onErrorJustReturn: ()),
            loadMoreData: loadMoreData.asSignal(onErrorJustReturn: 0),
            selectPostRow: tableView.rx.itemSelected.asSignal(),
            searchText: selectSearch.asDriver(onErrorJustReturn: ""),
            loadMoreSearch: loadMoreSearch.asDriver(onErrorJustReturn: 0))
        let output = viewModel.transform(input)
        
        output.loadData
            .bind(to: tableView.rx.items(cellIdentifier: "joinCell", cellType: MainTableViewCell.self)) { (row, repository, cell) in
                var skillSet = String()
                for i in 0..<repository.postSkillsets.count {
                    skillSet.append(" " + repository.postSkillsets[i].skill + " ")
                }
                
                let backimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(repository.img ?? "")")
                let userimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(repository.userImg ?? "")")
                cell.backImageView.kf.setImage(with: backimg)
                cell.projectLabel.text = repository.title
                cell.skilsLabel.text = skillSet
                cell.userImgView.kf.setImage(with: userimg)
            }.disposed(by: rx.disposeBag)

        output.loadMoreData.subscribe(onNext:{ data in
            for i in 0..<data.count {
                output.loadData.add(element: data[i])
            }
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.loadMoreSearch.subscribe(onNext:{ data in
            for i in 0..<data.count {
                output.loadData.add(element: data[i])
            }
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.data.drive().disposed(by: rx.disposeBag)
        output.data.drive(onNext: { _ in self.tableView.reloadData()}).disposed(by: rx.disposeBag)
        output.searchResult.emit(onCompleted : {
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        output.nextView.asObservable().subscribe(onNext: { id in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
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
