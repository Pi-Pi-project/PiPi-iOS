//
//  PwCodeViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/01.
//

import UIKit
import RxSwift
import TKFormTextField

class PwCodeViewController: UIViewController {

    @IBOutlet weak var emailTextField: TKFormTextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    private let viewModel = PwCheckViewModel()
    private let emailError = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardNotification()
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
        //api 바꿔야함
        let input = PwCheckViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
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
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "pwCheck") as? PwCheckViewController else { return }
        vc.email = emailTextField.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if ((note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = -20
        }
    }

    @objc func keyboardWillHide(note: NSNotification) {
        if ((note.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
}
