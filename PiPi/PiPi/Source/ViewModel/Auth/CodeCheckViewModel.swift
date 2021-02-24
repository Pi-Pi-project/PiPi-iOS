//
//  CodeCheckViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/26.
//

import Foundation
import RxCocoa
import RxSwift

class CodeCheckViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct input {
        let authCode: Driver<String>
        let doneTap: Driver<Void>
        let email: Driver<String>
    }
    
    struct output {
        let result: Signal<String>
        let isEnable: Driver<Bool>
    }
    
    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let info = Driver.combineLatest(input.authCode, input.email)
        let isEnable = info.map { !$0.0.isEmpty }
        let result = PublishSubject<String>()
        
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: {[weak self] code, email in
            guard let self = self else {return}
            api.checkAuthCode(email, code).subscribe(onNext: { response in
                switch response {
                case .ok:
                    result.onCompleted()
                case .noToken:
                    result.onNext("이메일 인증 실패")
                default:
                    result.onNext("인증번호가 맞지 않습니다.")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: ""), isEnable: isEnable.asDriver())
    }
}
