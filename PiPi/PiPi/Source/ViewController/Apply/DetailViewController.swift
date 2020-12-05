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
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        ppDetailTextView.layer.borderWidth = 0.5
        ppDetailTextView.layer.borderColor = UIColor.gray.cgColor
        ppDetailTextView.layer.cornerRadius = 10
        userImg.clipsToBounds = true
        userImg.layer.cornerRadius = 30
        
        applyBtn.rx.tap.subscribe(onNext: { _ in
            self.showAlert(title: "신청", message: "신청하시겠습니까?")
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        let input = DetailViewModel.input(
            loadDetail: loadDetail.asSignal(onErrorJustReturn: ()),
            selectIndexPath: selectIndexPath,
            selectApply: applyBtn.rx.tap.asDriver())
        let output = viewModel.transform(input)
        
        output.loadDetail.asObservable().subscribe(onNext: { result in
            let backimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(result.img)")
            self.backImageView.kf.setImage(with: backimg)
            let userimg = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(result.userImg ?? "")")
            self.userImg.load(url: userimg!)
            
            self.userImg.rx.tap.subscribe(onNext: { _ in
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as? SeeProfileViewController else { return }
                print(result.userEmail)
                vc.email = result.userEmail
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: self.rx.disposeBag)
            
            var skillSet = String()
            for i in 0..<result.postSkillsets.count {
                skillSet.append("  " + result.postSkillsets[i].skill)
            }
            skillSet.append("  ")
            self.userName.text = result.userNickname
            self.ppNameLabel.text = result.title
            self.ppIntroLabel.text = "  " + result.idea + "  "
            self.ppSkillLabel.text = skillSet
            self.ppDetailTextView.text =
                result.content
            self.ppMaxLabel.text = "\(result.max ?? 0)"
            self.setButton(self.applyBtn, result.applied)
            self.ppSkillLabel.layer.borderColor = UIColor.lightGray.cgColor
            self.ppSkillLabel.layer.borderWidth = 1
            self.setBorder(self.ppIntroLabel)
            self.setBorder(self.ppSkillLabel)
            
            if result.mine {
                self.applyBtn.setTitle("내 공고글", for: .normal)
                self.applyBtn.isEnabled = false
            }
            
        }).disposed(by: rx.disposeBag)
        
        output.resultApplyT.asObservable().subscribe(onCompleted: {
            self.setButton(self.applyBtn, true)
        }).disposed(by: rx.disposeBag)
        
        output.resultApplyF.asObservable().subscribe(onCompleted: {
            self.setButton(self.applyBtn, false)
        }).disposed(by: rx.disposeBag)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
