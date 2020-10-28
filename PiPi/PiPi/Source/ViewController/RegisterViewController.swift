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

class RegisterViewController: UIViewController {

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var rePwTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    var email = String()
    
    private let viewModel = RegisterViewModel()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
