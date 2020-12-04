//
//  EditProfileViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/15.
//

import UIKit
import ResizingTokenField
import RxSwift
import RxCocoa

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userSkillsText: UITextView!
    @IBOutlet weak var giturlTextField: UITextField!
    @IBOutlet weak var selectImageBtn: UIButton!
    @IBOutlet weak var doneTap: UIButton!
    @IBOutlet weak var fixPortfolioBtn: UIButton!
    @IBOutlet weak var introTextField: UITextField!
    
    var email = String()
    private let viewModel = SetProfileViewModel()
    private var imageData = BehaviorRelay<Data?>(value: nil)
    private var skillSet = BehaviorRelay<[String]?>(value: [])
    private let getEmail = BehaviorRelay<Void>(value: ())

    var giturl = String()
    var skills = String()
    var imageview = UIImage()
    var tokens = [Skills]()
    var skillArray = [String]()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        userSkillsText.layer.borderWidth = 0.4
        userSkillsText.layer.borderColor = UIColor.gray.cgColor
        giturlTextField.text = giturl
        userSkillsText.text = skills
        
        let array = skills.spaceArray()
        for i in 0..<array.count {
            tokens.append(Skills(title: array[i]))
        }
        skillArray.append(skills)
        
        userImageView.image = imageview
        
        self.selectImageBtn.rx.tap.subscribe(onNext: { _ in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        fixPortfolioBtn.rx.tap.subscribe(onNext: { _ in
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "portfolioVC") as! PorfolioViewController
            let navController = UINavigationController(rootViewController: VC1)
            self.present(navController, animated:true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
    }
    
    func bindViewModel() {
        let input = SetProfileViewModel.input(
            showEmail: getEmail.asDriver(),
            userImage: imageData.asDriver(),
            userSkill: skillSet.asDriver(onErrorJustReturn: nil),
            userGit: giturlTextField.rx.text.asDriver(onErrorJustReturn: ""),
            userEmail: Driver.just(email),
            userIntro: introTextField.rx.text.asDriver(onErrorJustReturn: nil),
            doneTap: doneTap.rx.tap.asSignal())
        let output = viewModel.transform(input)
        
        self.setButton(doneTap)
        
        userSkillsText.rx.text.subscribe(onNext: { text in
            self.skillArray = (text?.spaceArray())!
            self.skillSet.accept(self.skillArray)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onCompleted: { self.navigationController?.popViewController(animated: true)}
        ).disposed(by: rx.disposeBag)
        
        output.email.emit(onNext: { email in
            self.email = email
        }).disposed(by: rx.disposeBag)
        
    }
    
    
    class Skills: ResizingTokenFieldToken, Equatable {
        static func == (lhs: EditProfileViewController.Skills, rhs: EditProfileViewController .Skills) -> Bool {
            return lhs === rhs
        }

        var title: String

        init(title: String) {
            self.title = title
        }
    }
}

//extension EditProfileViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        guard textField == userSkillsText.textField else { return true }
//        guard let text = userSkillsText.text, !text.isEmpty else { return true }
//        userSkillsText.append(tokens: [Skills(title: text.stringUpper(text))], animated: true)
//        skillArray.append(userSkillsText.text ?? "")
//        userSkillsText.text = nil
//        return false
//    }
//}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            self.userImageView.image = originalImage
            imageData.accept(originalImage.jpegData(compressionQuality: 0.3))
        }
        self.dismiss(animated: true, completion: nil)
    }
}

