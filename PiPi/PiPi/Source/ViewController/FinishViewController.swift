//
//  FinishViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/20.
//

import UIKit
import RxSwift
import RxCocoa

class FinishViewController: UIViewController {

    @IBOutlet weak var contentView: UITextView!
    @IBOutlet weak var completeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        completeBtn.layer.borderWidth = 0.5
        completeBtn.layer.borderColor = UIColor.red.cgColor
        completeBtn.tintColor = .black
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


class FinishViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    
    struct input{
        let completedTap: Driver<Void>
    }
    
    struct output{
        let result: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = ProjectAPI()
        let result = PublishSubject<String>()
        
        input.completedTap.asObservable().subscribe(onNext: { _ in
            api.finishProject(0, "giturl", "introduce")
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: ""))
    }
}
