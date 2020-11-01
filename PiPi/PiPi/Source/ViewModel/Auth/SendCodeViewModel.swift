//
//  SendCodeViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/25.
//

import Foundation
import RxCocoa
import RxSwift

class SendCodeViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct input {
        let email: Driver<String>
        let doneTap: Signal<Void>
    }
    
    struct output {
        let isEnable: Driver<Bool>
        let result: Signal<String>
    }
    
    func transform(_ input: SendCodeViewModel.input) -> SendCodeViewModel.output {
        let api = AuthAPI()
        let info = input.email
        let isEnable = info.map { PiPiFilter.isEmpty($0) }
        let result = PublishSubject<String>()
    
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { email in
            api.sendAuthCode(email).subscribe(onNext: { response in
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