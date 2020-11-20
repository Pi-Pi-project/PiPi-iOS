//
//  SIgnInViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import TKFormTextField

class SIgnInViewController: UIViewController {

    @IBOutlet weak var emailTextField: TKFormTextField!
    @IBOutlet weak var pwTextField: TKFormTextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var findPwBtn: UIButton!
    
    private let viewModel = SignInViewModel()
    private let emailLabel = UILabel()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bindViewModel()
    }
    
    func setUI() {
        signInBtn.rx.tap.subscribe(onNext: { _ in
            if PiPiFilter.checkEmail(self.emailTextField.text!) {
                self.setUpErrorMessage(self.emailLabel, title: "이메일 형식이 맞지 않습니다", superTextField: self.emailTextField)
            }
        }).disposed(by: rx.disposeBag)
        
        findPwBtn.rx.tap.subscribe(onNext: { _ in
            self.moveScene("findVC")
        }).disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        let input = SignInViewModel.input(
            userEmail: emailTextField.rx.text.orEmpty.asDriver(),
            userPw: pwTextField.rx.text.orEmpty.asDriver(),
            doneTap: signInBtn.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.isEnable.drive(signInBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {_ in
            self.setButton(self.signInBtn)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(
            onNext: { self.setUpErrorMessage(self.errorLabel, title: $0, superTextField: self.pwTextField )},
            onCompleted: { self.moveReference() }).disposed(by: rx.disposeBag)
    }
}
