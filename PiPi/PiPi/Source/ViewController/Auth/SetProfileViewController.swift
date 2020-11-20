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

class SetProfileViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var skillsTextField: ResizingTokenField!
    @IBOutlet weak var gitTextField: UITextField!
    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var pickerBtn: UIButton!
    
    private let viewModel = SetProfileViewModel()
    private let errorLabel = UILabel()
    
    var email = String()
    let imageString = String()
    private var skillSet = [String]()
    private var imageData = BehaviorRelay<Data?>(value: nil)
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchToPickPhoto))
          userImageView.addGestureRecognizer(tapGesture)
          userImageView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        let input = SetProfileViewModel.input(
            userImage: imageData.asDriver(),
            userSkill: Driver.just(skillSet),
            userGit: gitTextField.rx.text.asDriver(),
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
    
    class Skills: ResizingTokenFieldToken, Equatable {
        static func == (lhs: SetProfileViewController.Skills, rhs: SetProfileViewController.Skills) -> Bool {
            return lhs === rhs
        }
        
        var title: String
        
        init(title: String) {
            self.title = title
        }
    }


}

extension SetProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == skillsTextField.textField else { return true }
        guard let text = skillsTextField.text, !text.isEmpty else { return true }
        skillsTextField.append(tokens: [Skills(title: text.stringUpper(text))], animated: true)
        skillSet.append(skillsTextField.text!)
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
