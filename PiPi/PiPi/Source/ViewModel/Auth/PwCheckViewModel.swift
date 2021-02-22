//
//  PwCheckViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/21.
//

import Foundation
import RxSwift
import RxCocoa

class PwCheckViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct input {
        let email: Driver<String>
        let doneTap: Signal<Void>
    }
    
    struct output {
        let isEnable: Driver<Bool>
        let result: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let info = input.email
        let isEnable = info.map { !$0.isEmpty }
        let result = PublishSubject<String>()
    
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { email in
            api.changPwSendEmail(email).subscribe(onNext: { response in
                switch response {
                case .ok:
                    print("onCompleted")
                    result.onCompleted()
                case .notFound: result.onNext("중복된 이메일입니다.")
                default: result.onNext("인증번호 보내기 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "인증번호 보내기 실패패"))
    }
}

