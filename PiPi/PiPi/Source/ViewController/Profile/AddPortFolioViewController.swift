//
//  AddPortFolioViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/17.
//

import UIKit
import TKFormTextField

class AddPortFolioViewController: UIViewController {

    @IBOutlet weak var nameTextField: TKFormTextField!
    @IBOutlet weak var gitTextField: TKFormTextField!
    @IBOutlet weak var introduceTextField: TKFormTextField!
    @IBOutlet weak var addBtn: UIButton!
    
    private let viewModel = AddPortfolioViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }
    
    func bindViewModel() {
        let input = AddPortfolioViewModel.input(
            proName: nameTextField.rx.text.orEmpty.asDriver(),
            proGit: gitTextField.rx.text.orEmpty.asDriver(),
            proIntro: introduceTextField.rx.text.orEmpty.asDriver(),
            addTap: addBtn.rx.tap.asDriver())
        let output = viewModel.transform(input)
        
        output.isEnable.drive(addBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: { [unowned self] _ in setButton(self.addBtn) }).disposed(by: rx.disposeBag)
        output.result.emit(onCompleted: {[unowned self] in dismiss(animated: true, completion: nil)}).disposed(by: rx.disposeBag)
    }
    
}
