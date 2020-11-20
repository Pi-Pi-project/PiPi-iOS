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
        output.isEnable.drive(onNext: {_ in
            self.setButton(self.addBtn)
        }).disposed(by: rx.disposeBag)
        output.result.emit(onCompleted: { self.dismiss(animated: true, completion: nil)}).disposed(by: rx.disposeBag)
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
