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
    
    private let viewModel = ChangeViewModel()
    private let errorLabel = UILabel()
    
    var email = String()
    
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
        output.isEnable.drive(onNext: {[unowned self] _ in setButton(changePwBtn)}).disposed(by: rx.disposeBag)
        output.result.emit(onNext: {[unowned self] in setUpErrorMessage(errorLabel, title: $0, superTextField: rePwTextField)
        }, onCompleted: {[unowned self] in moveScene("signIn")}).disposed(by: rx.disposeBag)
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
            view.frame.origin.y = -20
        }
    }

    @objc func keyboardWillHide(note: NSNotification) {
        if ((note.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            view.frame.origin.y = 0
        }
    }

}
