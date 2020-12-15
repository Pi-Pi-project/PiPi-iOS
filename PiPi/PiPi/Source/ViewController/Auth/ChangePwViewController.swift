//
//  ChangePwViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/01.
//

import UIKit
import RxSwift
import RxCocoa
import TKFormTextField

class ChangePwViewController: UIViewController {

    @IBOutlet weak var newPwTextField: TKFormTextField!
    @IBOutlet weak var rePwTextField: TKFormTextField!
    @IBOutlet weak var changePwBtn: UIButton!
    
    var email = String()
    
    private let viewModel = ChangeViewModel()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardNotification()
        bindViewModel()
    }
    
    func bindViewModel() {
        let input = ChangeViewModel.input(newPw: newPwTextField.rx.text.orEmpty.asDriver(),
                                          rePw: rePwTextField.rx.text.orEmpty.asDriver(),
                                          userEmail: Driver.just(email),
                                          doneTap: changePwBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)
        
        output.isEnable.drive(changePwBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {_ in
            self.setButton(self.changePwBtn)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onNext: {
            self.setUpErrorMessage(self.errorLabel, title: $0, superTextField: self.rePwTextField)
        }, onCompleted: {  self.moveScene("signIn")}).disposed(by: rx.disposeBag)
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
