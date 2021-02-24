//
//  FinishViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2021/02/24.
//

import Foundation
import RxSwift
import RxCocoa

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
        
        input.completedTap.asObservable().withLatestFrom(info).subscribe(onNext: {[weak self] id ,url, intro in
            guard let self = self else { return }
            api.finishProject(id, url, intro).subscribe(onNext: {response in
                
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
