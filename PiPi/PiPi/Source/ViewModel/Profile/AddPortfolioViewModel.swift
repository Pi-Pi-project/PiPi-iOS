//
//  AddPortfolioViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/17.
//

import Foundation
import RxSwift
import RxCocoa

class AddPortfolioViewModel: ViewModelType {
    let dispoedBag = DisposeBag()
    
    struct input {
        let proName: Driver<String>
        let proGit: Driver<String>
        let proIntro: Driver<String>
        let addTap: Driver<Void>
    }
    
    struct output {
        let result: Signal<String>
        let isEnable: Driver<Bool>
    }
    
    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let result = PublishSubject<String>()
        let info = Driver.combineLatest(input.proName, input.proGit, input.proIntro)
        let isEnable = info.map { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty }
        
        input.addTap.asObservable().withLatestFrom(info).subscribe(onNext: { name, giturl, intro in
            api.addPortfolios(name, giturl, intro).subscribe(onNext: { response in
                print(response)
                switch response {
                case .ok:
                    print("oncompleted")
                    result.onCompleted()
                default:
                    result.onNext("")
                }
            }).disposed(by: self.dispoedBag)
        }).disposed(by: dispoedBag)
        
        return output(result: result.asSignal(onErrorJustReturn: ""), isEnable: isEnable.asDriver(onErrorJustReturn: false))
    }
}
