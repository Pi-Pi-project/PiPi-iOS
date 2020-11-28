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
        let projectUrl: Driver<String>
        let projectIntro: Driver<String>
        let selectIndexPath: Driver<Int>
    }
    
    struct output{
        let result: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = ProjectAPI()
        let result = PublishSubject<String>()
        let info = Driver.combineLatest(input.selectIndexPath, input.projectUrl, input.projectIntro)
        
        input.completedTap.asObservable().withLatestFrom(info).subscribe(onNext: { id ,url, intro in
            api.finishProject(id, url, intro).subscribe(onNext: { response in
                print(response)
                switch response {
                case .ok:
                    result.onCompleted()
                default:
                    result.onNext("프로젝트 완료하는 중에 예상치 못한 오류")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "프로젝트 완료 실패"))
    }
}
