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
        bindViewModel()
    }

    func bindViewModel() {
        let input = PwCheckViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
                                            doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)
        
        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in setButton(self.nextBtn)}).disposed(by: rx.disposeBag)
        output.result.emit(onNext: {[unowned self] in setUpErrorMessage(emailError, title: $0, superTextField: emailTextField)},
        onCompleted: {[unowned self] in pushWithData()}).disposed(by: rx.disposeBag)
    }
    
    func pushWithData() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "pwCheck") as? PwCheckViewController else { return }
        vc.email = emailTextField.text!
        navigationController?.pushViewController(vc, animated: true)
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
