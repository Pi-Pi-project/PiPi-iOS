//
//  ProfileViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/15.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSkillLabel: UILabel!
    @IBOutlet weak var userGitLabel: UILabel!
    @IBOutlet weak var userIntroLabel: UILabel!
    @IBOutlet weak var portfolioTableView: UITableView!
    @IBOutlet weak var eidtProfileBtn: UIButton!
    @IBOutlet weak var changPwBtn: UIButton!
    
    private let viewModel = SeeProfileViewModel()
    private let loadProfile = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
        registerCell()
        view.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
    }

    override func viewWillAppear(_ animated: Bool) {
    }
    
    func bindViewModel() {
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
            portfolioSum.bind(to: self.portfolioTableView.rx.items(cellIdentifier: "portfolioCell", cellType: PortfolioTableViewCell.self)) { row, repository, cell in
                print(repository)
                cell.projectNameLabel.text = repository.title
                cell.giturlLabel.text = repository.giturl
                cell.moreLabel.text = repository.introduce
            }.disposed(by: self.rx.disposeBag)
            portfolioSum.accept(portfolioView)
            
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        eidtProfileBtn.rx.tap.subscribe(onNext: { _ in
            guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "editProfileVC") as? EditProfileViewController else { return }
            rvc.giturl = self.userGitLabel.text ?? ""
            rvc.skills = self.userSkillLabel.text ?? ""
            rvc.imageview = self.userImageView.image ?? UIImage(named: "")!

            self.navigationController?.pushViewController(rvc, animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func registerCell() {
        let nib = UINib(nibName: "PortfolioTableViewCell", bundle: nil)
        portfolioTableView.register(nib, forCellReuseIdentifier: "portfolioCell")
        portfolioTableView.rowHeight = 160
    }
}
