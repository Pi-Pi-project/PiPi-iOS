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
    private let showInfo = BehaviorRelay<Void>(value: ())
    private let email = PublishRelay<String>()
    private let category = ["Web", "MoblieApp", "DataScience", "System", "Network", "MachineLearning", "Security", "Embedded", "VR", "Game" ]
    
    var check = Bool()
    var count: Int = 0
    var model = [postModel]()
    
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
        if let view = UIApplication.shared.windows.filter({$0.isKeyWindow}
        ).first{
            view.addSubview(floatingButton)
            setupUI()
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData.accept(())
        tableView.reloadData()
        navigationController?.isNavigationBarHidden = false
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
        
        tableView.rx.didScroll.asObservable().subscribe(onNext: {[unowned self] _ in
            if tableView.contentOffset.y > tableView.contentSize.height - tableView.bounds.size.height {
                if check {
                    loadMoreSearch.onNext(count)
                    count += 1
                }else {
                    loadMoreData.onNext(count)
                    count += 1
                    tableView.reloadData()
                }
            }
        }).disposed(by: rx.disposeBag)
        
        tableView.rowHeight = 200
    }
    
    func bindViewModel() {
        let input = MainViewModel.input(
            showInfo: showInfo.asSignal(onErrorJustReturn: ()),
            email: email.asSignal(onErrorJustReturn: "312"),
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
        
        output.email.emit(onNext: {[unowned self] result in email.accept(result) }).disposed(by: rx.disposeBag)
        
        output.likePost.subscribe(onNext: {[unowned self] data in
            for i in 0..<data.count {
                output.loadData.insert(element: data[i])
            }
            tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        Observable.of(output.loadMoreData, output.loadMoreSearch).merge().subscribe(onNext: {[unowned self] data in
            for i in 0..<data.count {
                output.loadData.add(element: data[i])
            }
            tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.searchResult.emit(onCompleted : {[unowned self] in tableView.reloadData() }).disposed(by: rx.disposeBag)
        
        output.nextView.asObservable().subscribe(onNext: {[unowned self] id in
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
            vc.selectIndexPath = id
            navigationController?.pushViewController(vc, animated: true)
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
    
    func setupSearchBar() {
        searchBar.placeholder = "카테고리로 검색하기"
        searchBar.optionArray = category
        searchBar.selectedRowColor = UIColor().hexUIColor(hex: "61BFAD")
        
        searchBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            selectSearch.accept(category[searchBar.selectedIndex ?? 0])
            check = true
            count = 0
        }).disposed(by: rx.disposeBag)
    }
    
    @objc func floatingBtn(){
        let pushVC = storyboard?.instantiateViewController(withIdentifier: "postVC") as! PostViewController
        present(pushVC, animated: true, completion: nil)
    }
}
