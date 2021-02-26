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
        navigationController?.isNavigationBarHidden = true

        userImageView.layer.cornerRadius = 50
        portfolioTableView.layer.cornerRadius = 20
        portfolioTableView.allowsSelection = false
        view.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")

        bindViewModel()
        setupUI()
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        portfolioTableView.delegate = nil
        portfolioTableView.dataSource = nil
        
        loadProfile.accept(())
    }
    
    func bindViewModel() {
        let input = SeeProfileViewModel.input(
            profileUser: SeeProfileViewModel.email.asDriver(onErrorJustReturn: ""),
            loadProfile: loadProfile.asSignal(onErrorJustReturn: ()),
            showInfo: showInfo.asSignal(onErrorJustReturn: ()))
        
        let output = viewModel.transform(input)
        
        SeeProfileViewModel.loadProfile.bind {[unowned self] result in
            var skillSet = String()
            for i in 0..<result.skills.count {
                skillSet.append(" " + result.skills[i].skill)
            }
            
            userNameLabel.text = result.nickname
            userImageView.kf.setImage(with: URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(result.profileImg)"))
            userSkillLabel.text = skillSet
            userGitLabel.text = result.giturl
            userIntroLabel.text = result.introduce
            
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
        }.disposed(by: rx.disposeBag)
        
        output.result.emit(onCompleted: {[unowned self] in loadProfile.accept(()) }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        eidtProfileBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            guard let rvc = storyboard?.instantiateViewController(withIdentifier: "editProfileVC") as? EditProfileViewController else { return }
            rvc.giturl = userGitLabel.text ?? ""
            rvc.skills = userSkillLabel.text ?? ""
            rvc.loadImage = userImageView.image ?? UIImage(named: "")!

            navigationController?.pushViewController(rvc, animated: true)
        }).disposed(by: rx.disposeBag)
        
        changPwBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            let mainView: UIStoryboard = UIStoryboard(name: "Auth", bundle: nil)
            let nextVC = mainView.instantiateViewController(identifier: "findVC")
            nextVC.modalPresentationStyle = .fullScreen
            present(nextVC, animated: false, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
    
    func registerCell() {
        let nib = UINib(nibName: "PortfolioTableViewCell", bundle: nil)
        portfolioTableView.register(nib, forCellReuseIdentifier: "portfolioCell")
        portfolioTableView.rowHeight = 160
    }
}
