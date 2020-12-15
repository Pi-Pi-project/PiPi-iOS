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
    
    var email = String()
    
    private let viewModel = RegisterViewModel()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardNotification()
        bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        let input = RegisterViewModel.input(email: Driver.just(email),
                                            nickname: nicknameTextField.rx.text.orEmpty.asDriver(),
                                            userPw: pwTextField.rx.text.orEmpty.asDriver(),
                                            userRepw: rePwTextField.rx.text.orEmpty.asDriver(),
                                            doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)
        
        output.isEnabel.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnabel.drive(onNext: { _ in
            self.setButton(self.nextBtn)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onNext: {
            self.setUpErrorMessage(self.errorLabel, title: $0, superTextField: self.rePwTextField)
        }, onCompleted: { [unowned self] in nextWithData()}).disposed(by: rx.disposeBag)
    }
    
    func nextWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "setProfile") as? SetProfileViewController else { return }
        vc.email = email
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
