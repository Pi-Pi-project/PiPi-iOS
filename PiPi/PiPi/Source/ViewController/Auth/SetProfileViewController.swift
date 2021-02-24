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
    private let getEmail = BehaviorRelay<Void>(value: ())
    private var skillSet = BehaviorRelay<[String]?>(value: [])
    private var imageData = BehaviorRelay<Data?>(value: nil)
    
    var email = String()
    let imageString = String()
    var skillArray = [String]()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.layer.borderWidth = 0.5
        userImageView.layer.borderColor = UIColor.black.cgColor
        
        skillsTextField.textFieldDelegate = self
        skillsTextField.layer.borderWidth = 0.5
        skillsTextField.layer.borderColor = UIColor.gray.cgColor
        addKeyboardNotification()
        
        pickerBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        bindViewModel()
    }
    
    func bindViewModel() {
        let input = SetProfileViewModel.input(
            showEmail: getEmail.asDriver(),
            userImage: imageData.asDriver(),
            userSkill: skillSet.asDriver(),
            userGit: gitTextField.rx.text.asDriver(),
            userEmail: Driver.just(email),
            userIntro: introTextField.rx.text.asDriver(onErrorJustReturn: nil),
            doneTap: completeBtn.rx.tap.asSignal())
        
        let output = viewModel.transform(input)
        
        output.isEnable.drive(completeBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in setButton(completeBtn)}).disposed(by: rx.disposeBag)
        output.result.emit(onNext: {[unowned self] in setUpErrorMessage(errorLabel, title: $0, superTextField: gitTextField)},
        onCompleted: { [unowned self] in moveReference()}).disposed(by: rx.disposeBag)
        output.email.emit(onNext: {[unowned self] email in self.email = email }).disposed(by: rx.disposeBag)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotomain"{
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationTopViewController = destinationNavigationController.topViewController as! JoinViewController
            self.navigationController?.pushViewController(destinationTopViewController, animated: false)
        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
