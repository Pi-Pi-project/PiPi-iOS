//
//  SendCodeViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/21.
//

import UIKit

class SendCodeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var introLabel: UILabel!
    
    private let viewModel = SendCodeViewModel()
    private let emailError = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        nextBtn.rx.tap
            .subscribe(onNext: {
                if PiPiFilter.checkEmail(self.emailTextField.text!) {
                    self.setUpErrorHidden(self.emailError)
                } else {
                    self.setUpErrorMessage(self.emailError, title: "이메일 형식이 맞지 않습니다.", superTextField: self.emailTextField)
                }
            }).disposed(by: rx.disposeBag)
    }

    
    func bindViewModel() {
        let input = SendCodeViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
                                            doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)
        
        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {_ in
            self.setButton(self.nextBtn)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onNext: {
            self.setUpErrorMessage(self.emailError, title: $0, superTextField: self.emailTextField)
        }, onCompleted: {  self.nextWithData()}).disposed(by: rx.disposeBag)
    }
    
    func nextWithData() {
        print("authCode")
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "authCode") as? CodeCheckViewController else { return }
        vc.email = emailTextField.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
