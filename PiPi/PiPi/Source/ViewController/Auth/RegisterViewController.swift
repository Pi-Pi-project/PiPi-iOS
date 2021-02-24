//
//  RegisterViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/26.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx
import TKFormTextField

class RegisterViewController: UIViewController {

    @IBOutlet weak var nicknameTextField: TKFormTextField!
    @IBOutlet weak var pwTextField: TKFormTextField!
    @IBOutlet weak var rePwTextField: TKFormTextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    private let viewModel = RegisterViewModel()
    private let errorLabel = UILabel()
    
    var email = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardNotification()
        bindViewModel()
    }
    
    func bindViewModel() {
        let input = RegisterViewModel.input(email: Driver.just(email),
                                            nickname: nicknameTextField.rx.text.orEmpty.asDriver(),
                                            userPw: pwTextField.rx.text.orEmpty.asDriver(),
                                            userRepw: rePwTextField.rx.text.orEmpty.asDriver(),
                                            doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)
        
        output.isEnabel.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnabel.drive(onNext: {[unowned self] _ in setButton(nextBtn)}).disposed(by: rx.disposeBag)
        output.result.emit(onNext: {[unowned self] in
            setUpErrorMessage(errorLabel, title: $0, superTextField: rePwTextField)
        }, onCompleted: { [unowned self] in pushWithData()}).disposed(by: rx.disposeBag)
    }
    
    func pushWithData() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "setProfile") as? SetProfileViewController else { return }
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
