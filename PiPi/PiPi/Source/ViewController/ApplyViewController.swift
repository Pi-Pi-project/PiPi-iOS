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

class ApplyViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let viewModel = ApplyViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())

    
    lazy var floatingButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .magenta
        button.addTarget(self, action: #selector(floatingBtn), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        registerCell()
        // Do any additional setup after loading the view.
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
        
        tableView.rowHeight = 200
    }
    
    func bindViewModel() {
        let input = ApplyViewModel.input(loadData: loadData.asSignal(onErrorJustReturn: ()), selectApplyRow: tableView.rx.itemSelected.asSignal())
        let output = viewModel.transform(input)
        
        ApplyViewModel.loadApplyData
            .bind(to: tableView.rx.items(cellIdentifier: "joinCell", cellType: MainTableViewCell.self)) { (row, repository, cell) in
                
                var skillSet = String()
                
                for i in 0..<repository.postSkillsets.count {
                    skillSet = repository.postSkillsets[i].skill
                }
                let backimg = URL(string: "http://10.156.145.141:8080/image/\(repository.img ?? "")/")
                let userimg = URL(string: "http://10.156.145.141:8080/image/\(repository.userImg ?? "")/")
                
                cell.backImageView.kf.setImage(with: backimg)
                cell.projectLabel.text = repository.title
                cell.skilsLabel.text = skillSet
                cell.userImgBtn.imageView?.kf.setImage(with: userimg)
            }.disposed(by: rx.disposeBag)
        
        
        output.detailView.asObservable().subscribe(onNext: { id in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
            vc.selectIndexPath = id
            print(id)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onCompleted : { self.tableView.reloadData() }).disposed(by: rx.disposeBag)
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
        floatingButton.layer.borderColor = UIColor.systemPink.cgColor
        floatingButton.layer.borderWidth = 4
    }
    
    @objc func floatingBtn(){
        let pushVC = self.storyboard?.instantiateViewController(withIdentifier: "") as! ViewController
        self.navigationController?.pushViewController(pushVC, animated: true)
    }

}
