//
//  SetProfileViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/28.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SetProfileViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var skillTextField: UITextField!
    @IBOutlet weak var gitTextField: UITextField!
    @IBOutlet weak var completeBtn: UIButton!
    
    private let viewModel = SetProfileViewModel()
    private let errorLabel = UILabel()
    let imagePicker = UIImagePickerController()
    var email = String()
    let imageString = String()
    let skillSet = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchToPickPhoto))
          userImageView.addGestureRecognizer(tapGesture)
          userImageView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        let input = SetProfileViewModel.input(userImage: Driver.just(imageString),
                                              userSkill: Driver.just(skillSet),
                                              userGit: gitTextField.rx.text.orEmpty.asDriver(),
                                              userEmail: Driver.just(email),
                                              doneTap: completeBtn.rx.tap.asSignal())
        
        let output = viewModel.transform(input)
        
        output.isEnable.drive(completeBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: { _ in
            self.setButton(self.completeBtn)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onNext: {
            self.setUpErrorMessage(self.errorLabel, title: $0, superTextField: self.gitTextField)
        }, onCompleted: { [unowned self] in moveScene("main")}).disposed(by: rx.disposeBag)
    }

    @objc func touchToPickPhoto() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
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
