//
//  FinishViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/20.
//

import UIKit
import RxSwift
import RxCocoa
import TKFormTextField

class FinishViewController: UIViewController {

    @IBOutlet weak var contentView: UITextView!
    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var giturlTextField: TKFormTextField!
    @IBOutlet weak var introTextView: UITextView!
    
    var selectIndexPath = Int()
    
    private let viewModel = FinishViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupUI()
    }
    
    func setupUI() {
        completeBtn.layer.borderWidth = 0.5
        completeBtn.layer.cornerRadius = 10
        completeBtn.layer.borderColor = UIColor.red.cgColor
        completeBtn.tintColor = .black
    }

    func bindViewModel() {
        let input = FinishViewModel.input(completedTap: completeBtn.rx.tap.asDriver(), projectUrl: giturlTextField.rx.text.orEmpty.asDriver(), projectIntro: introTextView.rx.text.orEmpty.asDriver(), selectIndexPath: Driver.just(selectIndexPath))
        let output = viewModel.transform(input)
        
        output.result.emit(onCompleted: {
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
}
