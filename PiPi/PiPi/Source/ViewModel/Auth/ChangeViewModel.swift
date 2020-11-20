//
//  ChangeViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/01.
//

import Foundation
import RxSwift
import RxCocoa

class ChangeViewModel: ViewModelType {
     private let disposeBag = DisposeBag()
    
    struct input {
        let newPw: Driver<String>
        let rePw: Driver<String>
        let userEmail: Driver<String>
        let doneTap: Signal<Void>
    }
    
    struct output {
        let result: Signal<String>
        let isEnable: Driver<Bool>
    }
    
    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let result = PublishSubject<String>()
        let info = Driver.combineLatest(input.newPw, input.rePw, input.userEmail)
        let isEnable = info.map { $0.0 == $0.1 && !$0.0.isEmpty}
        
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext:{ newPw, rePw, userE in
            api.changePassword(userE, rePw).subscribe(onNext: { response in
                switch response {
                case .ok:
                    return result.onCompleted()
                default:
                    return result.onNext("비밀번호 설정 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "비밀번호 재등록 실패"), isEnable: isEnable.asDriver())
    }
}
