//
//  PostViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/05.
//

import UIKit
import TKFormTextField
import ResizingTokenField
import RxSwift
import RxCocoa
import NSObject_Rx
import Photos
import iOSDropDown

class PostViewController: UIViewController {
    @IBOutlet weak var proTitleTF: TKFormTextField!
    @IBOutlet weak var proCategoryTF: DropDown!
    @IBOutlet weak var proSkillSetTF: ResizingTokenField!
    @IBOutlet weak var proIdeaTF: TKFormTextField!
    @IBOutlet weak var proContentTV: UITextView!
    @IBOutlet weak var maxSwitch: UIStepper!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var libraryBtn: UIButton!
    @IBOutlet weak var proImageView: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    
    private let viewModel = PostViewModel()
    
    var skillSet = PublishRelay<[String]>()
    var skillArray = [String]()
    var imagURL = BehaviorRelay<Data?>(value: nil)
    var selectCategory = PublishRelay<String>()
    let category = ["Web", "MoblieApp", "DataScience", "System", "Network", "MachineLearning", "Security", "Embedded", "VR", "Game" ]
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupUI()
    }
    
    func bindViewModel() {
        let input = PostViewModel.input(
            title: proTitleTF.rx.text.orEmpty.asDriver(),
            category: selectCategory.asDriver(onErrorJustReturn: ""),
            skills: skillSet.asDriver(onErrorJustReturn: []),
            idea: proIdeaTF.rx.text.orEmpty.asDriver(),
            content: proContentTV.rx.text.orEmpty.asDriver(),
            max: maxSwitch.rx.value.asDriver(),
            img: imagURL.asDriver(onErrorJustReturn: nil),
            postTap: postBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)
        
        output.isEnable.drive(postBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in setButton(postBtn) }).disposed(by: rx.disposeBag)
        output.result.emit(onNext: { print($0) },
            onCompleted: {[unowned  self] in
                let alert = UIAlertController(title: "공고 글 작성시 주의", message: "공고 마감 기한은 2주입니다.공고글 작성부터 2주가 지나면 자동으로 삭제됩니다.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                    dismiss(animated: true, completion: nil)
                    navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                self.present(alert, animated: true)
            }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        proContentTV.layer.borderColor = UIColor().hexUIColor(hex: "").cgColor
        proContentTV.layer.borderWidth = 1
        proSkillSetTF.layer.borderWidth = 1
        proSkillSetTF.layer.borderColor = UIColor.darkGray.cgColor
        proSkillSetTF.preferredTextFieldReturnKeyType = .done
        proSkillSetTF.preferredTextFieldEnablesReturnKeyAutomatically = true
        proSkillSetTF.textFieldDelegate = self
        proSkillSetTF.placeholder = "프로젝트 스킬"
        proCategoryTF.optionArray = category
        proCategoryTF.selectedRowColor = UIColor().hexUIColor(hex: "61BFAD")
        
        libraryBtn.rx.tap.subscribe(onNext: {[unowned self] _ in present(imagePicker, animated: true, completion: nil) }).disposed(by: rx.disposeBag)
        
        maxSwitch.rx.controlEvent(.touchUpInside).subscribe(onNext: {[unowned self] _ in
            let value = Int(maxSwitch.value)
            maxLabel.text = String(value)
        }).disposed(by: rx.disposeBag)
        
        postBtn.rx.tap.subscribe(onNext: {[unowned self]  _ in
            selectCategory.accept(category[proCategoryTF.selectedIndex ?? 0])
            skillSet.accept(skillArray)
        }).disposed(by: rx.disposeBag)
    }
    
    class Skills: ResizingTokenFieldToken, Equatable {
        static func == (lhs: PostViewController.Skills, rhs: PostViewController.Skills) -> Bool {
            return lhs === rhs
        }
        
        var title: String
        
        init(title: String) {
            self.title = title
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension PostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == proSkillSetTF.textField else { return true }
        guard let text = proSkillSetTF.text, !text.isEmpty else { return true }
        proSkillSetTF.append(tokens: [Skills(title: text.stringUpper(text))], animated: true)
        proSkillSetTF.text = text.stringUpper(text)
        skillArray.append(text.stringUpper(text))
        proSkillSetTF.text = nil
        return false
    }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            self.proImageView.image = originalImage
            guard let imageData = originalImage.jpegData(compressionQuality: 0.4) else {
                print("Could not get JPEG representation of UIImage")
                return
            }
            imagURL.accept(imageData)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
