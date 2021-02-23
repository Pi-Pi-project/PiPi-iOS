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
    
    private let viewModel = SetProfileViewModel()
    private var imageData = BehaviorRelay<Data?>(value: nil)
    private var skillSet = BehaviorRelay<[String]?>(value: [])
    private let getEmail = BehaviorRelay<Void>(value: ())
    
    var email = String()
    var giturl = String()
    var skills = String()
    var loadImage = UIImage()
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
        userImageView.image = loadImage
        
        let array = skills.spaceArray()
        for i in 0..<array.count {
            tokens.append(Skills(title: array[i]))
        }
        skillArray.append(skills)
        
        selectImageBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        fixPortfolioBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            let vc = storyboard?.instantiateViewController(withIdentifier: "portfolioVC") as! PorfolioViewController
            let naviController = UINavigationController(rootViewController: vc)
            self.present(naviController, animated:true, completion: nil)
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
        
        userSkillsText.rx.text.subscribe(onNext: {[unowned self] text in
            skillArray = (text?.spaceArray())!
            skillSet.accept(skillArray)
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onCompleted: { [unowned self] in navigationController?.popViewController(animated: true)}
        ).disposed(by: rx.disposeBag)
        
        output.email.emit(onNext: {[unowned self] email in
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

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            self.userImageView.image = originalImage
            imageData.accept(originalImage.jpegData(compressionQuality: 0.3))
        }
        self.dismiss(animated: true, completion: nil)
    }
}

