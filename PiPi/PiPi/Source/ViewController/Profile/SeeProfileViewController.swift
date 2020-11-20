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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        bindViewModel()
    }
    
    func bindViewModel() {
        print("com")
        let input = SeeProfileViewModel.input(profileUser: Driver.just(""), loadProfile: loadProfile.asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input)
        
        SeeProfileViewModel.loadProfile.asObservable().subscribe(onNext: { result in
            let profileImg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(result.profileImg)")
            self.userNameLabel.text = result.nickname
            self.userImageView.kf.setImage(with: profileImg)
            self.circleOfImageView(self.userImageView)
            
            var skillSet = String()
            for i in 0..<result.skills.count {
                skillSet.append(" " + result.skills[i].skill)
            }
            
            self.userSkillLabel.text = skillSet
            self.userGitLabel.text = result.giturl
            self.userIntroLabel.text = result.introduce
            
            var portfolioView = [portfolio]()
            portfolioView.append(result.firstPortfolio)
            portfolioView.append(result.secondPortfolio)
            
            let portfolioSum = PublishRelay<[portfolio]>()
            portfolioSum.accept(portfolioView)
            
            portfolioSum.bind(to: self.portfolioTableView.rx.items(cellIdentifier: "portfolioCell", cellType: PortfolioTableViewCell.self)) { (row, item, cell) in
                cell.giturlLabel.text = item.giturl
                cell.projectNameLabel.text = item.title
                cell.moreLabel.text = item.introduce
            }.disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
    }
    
    func registerCell() {
       let nib = UINib(nibName: "PortfolioTableViewCell", bundle: nil)
        portfolioTableView.register(nib, forCellReuseIdentifier: "portfolioCell")
        portfolioTableView.rowHeight = 140
        portfolioTableView.numberOfRows(inSection: 2)
    }
}