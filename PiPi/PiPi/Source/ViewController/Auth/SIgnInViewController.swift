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
    @IBOutlet weak var autoAuthBtn: UIButton!
    
    private let viewModel = SignInViewModel()
    private let emailLabel = UILabel()
    private let errorLabel = UILabel()
    private var autoLogin = BehaviorRelay<Bool>(value: false)
    private let loadAuto = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bindViewModel()
    }
    
    func setUI() {
        findPwBtn.rx.tap.subscribe(onNext: {[unowned self] _ in moveScene("findVC") }).disposed(by: rx.disposeBag)
        
        autoAuthBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            autoAuthBtn.isSelected = !autoAuthBtn.isSelected
            autoLogin.accept(autoAuthBtn.isSelected)
        }).disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        let input = SignInViewModel.input(
            userEmail: emailTextField.rx.text.orEmpty.asDriver(),
            userPw: pwTextField.rx.text.orEmpty.asDriver(),
            doneTap: signInBtn.rx.tap.asSignal(),
            isAuto: autoLogin.asDriver(onErrorJustReturn: false),
            loadAutoLogin: loadAuto.asSignal(onErrorJustReturn: ())
        )
        let output = viewModel.transform(input)
        
        output.isEnable.drive(signInBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in
            setButton(signInBtn)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(
            onNext: {[unowned self] in setUpErrorMessage(errorLabel, title: $0, superTextField: pwTextField )},
            onCompleted: {[unowned self] in moveReference() }
        ).disposed(by: rx.disposeBag)
    }
}
