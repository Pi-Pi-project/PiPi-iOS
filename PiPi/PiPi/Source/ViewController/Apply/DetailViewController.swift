//
//  DetailViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class DetailViewController: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var userImg: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var ppNameLabel: UILabel!
    @IBOutlet weak var ppSkillLabel: UILabel!
    @IBOutlet weak var ppIntroLabel: UILabel!
    @IBOutlet weak var ppDetailTextView: UITextView!
    @IBOutlet weak var ppMaxLabel: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    
    private let viewModel = DetailViewModel()
    private let loadDetail = BehaviorRelay<Void>(value: ())
    
    var selectIndexPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        ppDetailTextView.layer.borderWidth = 0.5
        ppDetailTextView.layer.borderColor = UIColor.gray.cgColor
        ppDetailTextView.layer.cornerRadius = 10
        userImg.clipsToBounds = true
        userImg.layer.cornerRadius = 30
        applyBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        applyBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            showAlert(title: "신청", message: "신청하시겠습니까?")
            navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        let input = DetailViewModel.input(
            loadDetail: loadDetail.asSignal(onErrorJustReturn: ()),
            selectIndexPath: selectIndexPath,
            selectApply: applyBtn.rx.tap.asDriver())
        let output = viewModel.transform(input)
        
        output.loadDetail.bind {[unowned self] result in
            let backimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(result.img)")
            backImageView.kf.setImage(with: backimg)
            let userimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(result.userImg ?? "")")
            userImg.load(url: userimg!)
            
            var skillSet = String()
            for i in 0..<result.postSkillsets.count {
                skillSet.append("  " + result.postSkillsets[i].skill)
            }
            
            skillSet.append("  ")
            userName.text = result.userNickname
            ppNameLabel.text = result.title
            ppIntroLabel.text = "  " + result.idea + "  "
            ppDetailTextView.text = result.content
            ppMaxLabel.text = "\(result.max ?? 0)"
            ppSkillLabel.layer.borderColor = UIColor.lightGray.cgColor
            ppSkillLabel.layer.borderWidth = 1
            ppSkillLabel.text = result.postSkillsets.isEmpty ? " 스킬이 지정되지 않았습니다. " : skillSet
            
            if result.mine {
                applyBtn.setTitle("내 공고글", for: .normal)
                applyBtn.isEnabled = false
            }
            
            userImg.rx.tap.subscribe(onNext: {[unowned self] _ in
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? SeeProfileViewController else { return }
                vc.email = result.userEmail
                navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: self.rx.disposeBag)
            
            setButton(applyBtn, result.applied)
            setBorder(ppIntroLabel)
            setBorder(ppSkillLabel)
        }.disposed(by: rx.disposeBag)
        
        output.resultApplyT.asObservable().subscribe(onCompleted: {[unowned self] in setButton(applyBtn, true) }).disposed(by: rx.disposeBag)
        output.resultApplyF.asObservable().subscribe(onCompleted: {[unowned self] in setButton(applyBtn, false) }).disposed(by: rx.disposeBag)
    }
}
