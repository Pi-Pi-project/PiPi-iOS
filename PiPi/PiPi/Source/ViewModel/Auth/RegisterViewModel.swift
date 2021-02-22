//
//  RegisterViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/28.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct input {
        let email: Driver<String>
        let nickname: Driver<String>
        let userPw: Driver<String>
        let userRepw: Driver<String>
        let doneTap: Signal<Void>
    }
    
    struct output {
        let isEnabel: Driver<Bool>
        let result: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let result = PublishSubject<String>()
        let info = Driver.combineLatest(input.email, input.nickname, input.userRepw)
        let isEnable = info.map{ !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty }
        
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { email, nickname, userRepw in
            api.register(email, userRepw, nickname).subscribe(onNext: { response in
                switch response {
                case .ok:
                    return result.onCompleted()
                default:
                    return result.onNext("가입이 되지 않음")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(isEnabel: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "회원가입 실패"))
    }
}
