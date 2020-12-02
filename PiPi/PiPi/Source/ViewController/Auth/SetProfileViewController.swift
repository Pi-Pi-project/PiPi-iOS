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
import ResizingTokenField
import TKFormTextField

class SetProfileViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var skillsTextField: ResizingTokenField!
    @IBOutlet weak var gitTextField: TKFormTextField!
    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var pickerBtn: UIButton!
    @IBOutlet weak var introTextField: TKFormTextField!
    
    private let viewModel = SetProfileViewModel()
    private let errorLabel = UILabel()
    
    var email = String()
    let imageString = String()
    var skillArray = [String]()
    private var skillSet = BehaviorRelay<[String]?>(value: [])
    private var imageData = BehaviorRelay<Data?>(value: nil)
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        skillsTextField.textFieldDelegate = self
        skillsTextField.layer.borderWidth = 0.5
        skillsTextField.layer.borderColor = UIColor.gray.cgColor
        
        completeBtn.rx.tap.subscribe(onNext: { _ in
            print(self.skillArray)
        }).disposed(by: rx.disposeBag)
        
        pickerBtn.rx.tap.subscribe(onNext: { _ in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        bindViewModel()
    }
    
    func bindViewModel() {
        let input = SetProfileViewModel.input(
            userImage: imageData.asDriver(),
            userSkill: skillSet.asDriver(),
            userGit: gitTextField.rx.text.asDriver(),
            userEmail: Driver.just(email),
            doneTap: completeBtn.rx.tap.asSignal())
        
        let output = viewModel.transform(input)
        
        output.isEnable.drive(completeBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: { _ in
            self.setButton(self.completeBtn)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(
            onNext: { self.setUpErrorMessage(self.errorLabel, title: $0, superTextField: self.gitTextField)},
            onCompleted: { [unowned self] in
                self.moveReference()
            }
        ).disposed(by: rx.disposeBag)
    }
    
    class Skills: ResizingTokenFieldToken, Equatable {
        static func == (lhs: SetProfileViewController.Skills, rhs: SetProfileViewController.Skills) -> Bool {
            return lhs === rhs
        }
        
        var title: String
        
        init(title: String) {
            self.title = title
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotomain"{
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationTopViewController = destinationNavigationController.topViewController as! JoinViewController
            self.navigationController?.pushViewController(destinationTopViewController, animated: false)
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

extension SetProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == skillsTextField.textField else { return true }
        guard let text = skillsTextField.text, !text.isEmpty else { return true }
        skillsTextField.append(tokens: [Skills(title: text.stringUpper(text))], animated: true)
        skillArray.append(text.stringUpper(text))
        skillSet.accept(skillArray)
        skillsTextField.text = nil
        return false
    }
}

extension SetProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            self.userImageView.image = originalImage
            imageData.accept(originalImage.jpegData(compressionQuality: 0.3))
        }
        self.dismiss(animated: true, completion: nil)
    }
}
