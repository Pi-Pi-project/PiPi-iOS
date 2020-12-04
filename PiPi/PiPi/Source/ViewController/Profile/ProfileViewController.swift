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
    private let showInfo = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        userImageView.layer.cornerRadius = 50
        portfolioTableView.layer.cornerRadius = 20

        bindViewModel()
        setupUI()
        registerCell()
        view.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.portfolioTableView.delegate = nil
        self.portfolioTableView.dataSource = nil
        
        loadProfile.accept(())
    }
    
    func bindViewModel() {
        let input = SeeProfileViewModel.input(
            profileUser: SeeProfileViewModel.email.asDriver(onErrorJustReturn: ""),
            loadProfile: loadProfile.asSignal(onErrorJustReturn: ()),
            showInfo: showInfo.asSignal(onErrorJustReturn: ()))
        
        let output = viewModel.transform(input)
        
        SeeProfileViewModel.loadProfile.asObservable().subscribe(onNext: { result in
            let profileImg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(result.profileImg)")
            self.userNameLabel.text = result.nickname
            self.userImageView.kf.setImage(with: profileImg)
            
            var skillSet = String()
            for i in 0..<result.skills.count {
                skillSet.append(" " + result.skills[i].skill)
            }
            
            self.userSkillLabel.text = skillSet
            self.userGitLabel.text = result.giturl
            self.userIntroLabel.text = result.introduce
            
            var portfolioView = [portfolio?]()
            portfolioView.append(result.firstPortfolio ?? nil)
            portfolioView.append(result.secondPortfolio ?? nil)

            let portfolioSum = PublishRelay<[portfolio?]>()
            portfolioSum.bind(to: self.portfolioTableView.rx.items(cellIdentifier: "portfolioCell", cellType: PortfolioTableViewCell.self)) { row, repository, cell in
                cell.projectNameLabel.text = repository?.title
                cell.giturlLabel.text = repository?.giturl
                cell.moreLabel.text = repository?.introduce
            }.disposed(by: self.rx.disposeBag)
            portfolioSum.accept(portfolioView)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onCompleted: {
            self.loadProfile.accept(())
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
        
        changPwBtn.rx.tap.subscribe(onNext: { _ in
            let mainView: UIStoryboard = UIStoryboard(name: "Auth", bundle: nil)
            let nextVC = mainView.instantiateViewController(identifier: "findVC")
            nextVC.modalPresentationStyle = .fullScreen
            self.present(nextVC, animated: false, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
    
    func registerCell() {
        let nib = UINib(nibName: "PortfolioTableViewCell", bundle: nil)
        portfolioTableView.register(nib, forCellReuseIdentifier: "portfolioCell")
        portfolioTableView.rowHeight = 160
    }
}
