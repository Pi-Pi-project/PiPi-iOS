//
//  ChangePwViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/01.
//

import UIKit
import RxSwift
import RxCocoa

class ChangePwViewController: UIViewController {

    @IBOutlet weak var newPwTextField: UITextField!
    @IBOutlet weak var rePwTextField: UITextField!
    @IBOutlet weak var changePwBtn: UIButton!
    
    var email = String()
    
    private let viewModel = ChangeViewModel()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        }, onCompleted: {  self.moveScene("signin")}).disposed(by: rx.disposeBag)
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
