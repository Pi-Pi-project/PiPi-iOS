//
//  SendCodeViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/21.
//

import UIKit
import TKFormTextField

class SendCodeViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: TKFormTextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var introLabel: UILabel!
    
    private let viewModel = SendCodeViewModel()
    private let emailError = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardNotification()
        bindViewModel()
        
        nextBtn.rx.tap.subscribe(onNext: {[unowned self] in nextBtn.isEnabled = false }).disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        let input = SendCodeViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
                                            doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)
        
        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in setButton(self.nextBtn)}).disposed(by: rx.disposeBag)
        output.result.emit(onNext: {[unowned self] in
            setUpErrorMessage(emailError, title: $0, superTextField: emailTextField)
            nextBtn.isEnabled = true
        }, onCompleted: {[unowned self] in pushWithData()}
        ).disposed(by: rx.disposeBag)
    }
    
    func pushWithData() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "authCode") as? CodeCheckViewController else { return }
        vc.email = emailTextField.text!
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
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
