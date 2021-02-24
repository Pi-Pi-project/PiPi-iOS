//
//  CodeCheckViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import TKFormTextField

class CodeCheckViewController: UIViewController {

    @IBOutlet weak var codeTextField: TKFormTextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    private let viewModel = CodeCheckViewModel()
    private let authCodeLabel = UILabel()
    
    var email = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }
    
    func bindViewModel() {
        let input = CodeCheckViewModel.input(authCode: codeTextField.rx.text.orEmpty.asDriver(),
                                             doneTap: nextBtn.rx.tap.asDriver(),
                                             email: Driver.just(email))
        let output = viewModel.transform(input)
        
        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in setButton(self.nextBtn) }).disposed(by: rx.disposeBag)
        output.result.emit(onNext: {[unowned self] in
            setUpErrorMessage(self.authCodeLabel, title: $0, superTextField: self.codeTextField)
        }, onCompleted: { [unowned self] in pushWithData()}
        ).disposed(by: rx.disposeBag)
    }

    func pushWithData() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "register") as? RegisterViewController else { return }
        vc.email = email
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
