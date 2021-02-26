//
//  SeeProfileViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/13.
//

import UIKit
import RxSwift
import RxCocoa

class SeeProfileViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSkillLabel: UILabel!
    @IBOutlet weak var userGitLabel: UILabel!
    @IBOutlet weak var userIntroLabel: UILabel!
    @IBOutlet weak var portfolioTableView: UITableView!
    
    private let viewModel = SeeProfileViewModel()
    private let loadProfile = BehaviorRelay<Void>(value: ())
    private let showInfo = BehaviorRelay<Void>(value: ())
    
    var email = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = 50
        portfolioTableView.allowsSelection = false

        registerCell()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
        portfolioTableView.reloadData()
        portfolioTableView.delegate = nil
        portfolioTableView.dataSource = nil
    }
    
    func bindViewModel() {
        let input = SeeProfileViewModel.input(profileUser: Driver.just(email), loadProfile: loadProfile.asSignal(onErrorJustReturn: ()), showInfo: showInfo.asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input)
        
        SeeProfileViewModel.loadProfile.bind {[unowned self] result in
            var skillSet = String()
            for i in 0..<result.skills.count {
                skillSet.append(" " + result.skills[i].skill)
            }
            
            var portfolioView = [portfolio]()
            portfolioView.append(result.firstPortfolio ?? portfolio(id: 0, userEmail: "", title: "", giturl: "", introduce: ""))
            portfolioView.append(result.secondPortfolio ?? portfolio(id: 0, userEmail: "", title: "", giturl: "", introduce: ""))
            
            let portfolioSum = PublishRelay<[portfolio]>()
            portfolioSum.bind(to: portfolioTableView.rx.items(cellIdentifier: "portfolioCell", cellType: PortfolioTableViewCell.self)) { (row, item, cell) in
                cell.giturlLabel.text = item.giturl
                cell.projectNameLabel.text = item.title
                cell.moreLabel.text = item.introduce
            }.disposed(by: self.rx.disposeBag)
            portfolioSum.accept(portfolioView)
            
            userNameLabel.text = result.nickname
            userImageView.kf.setImage(with: URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(result.profileImg)"))
            userSkillLabel.text = skillSet
            userGitLabel.text = result.giturl
            userIntroLabel.text = result.introduce
        }.disposed(by: rx.disposeBag)
        
        output.result.emit(onNext: { error in
            print(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func registerCell() {
       let nib = UINib(nibName: "PortfolioTableViewCell", bundle: nil)
        portfolioTableView.register(nib, forCellReuseIdentifier: "portfolioCell")
        portfolioTableView.rowHeight = 120
    }
}
