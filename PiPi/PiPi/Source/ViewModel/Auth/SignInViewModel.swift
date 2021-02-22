//
//  SignInViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import RxSwift
import RxCocoa

class SignInViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct input {
        let userEmail: Driver<String>
        let userPw: Driver<String>
        let doneTap: Signal<Void>
        let isAuto: Driver<Bool>
        let loadAutoLogin: Signal<Void>
    }
    
    struct output {
        let isEnable: Driver<Bool>
        let result: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let info = Driver.combineLatest(input.userEmail, input.userPw, input.isAuto)
        let isEnable = info.map { !$0.0.isEmpty && !$0.1.isEmpty }
        let result = PublishSubject<String>()
        
        input.loadAutoLogin.asObservable().withLatestFrom(info).subscribe(onNext: { userE, userP, isAuto in
            if let userId = UserDefaults.standard.string(forKey: "id"){
                let userPw = UserDefaults.standard.string(forKey: "pw")!
                
                api.signIn(userId, userPw).subscribe(onNext: { response in
                    switch response {
                    case .ok:
                        result.onCompleted()
                    case .notFound:
                        print("")
                    default:
                        print("자동 로그인 실패")
                    }
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { userE, userP, isAuto in
            if isAuto {
                UserDefaults.standard.set(userE, forKey: "id")
                UserDefaults.standard.set(userP, forKey: "pw")
            }
            api.signIn(userE, userP).subscribe(onNext: { response in
                switch response {
                case .ok:
                    result.onCompleted()
                case .notFound:
                    result.onNext("이메일 또는 비밀번호가 틀렸습니다")
                default:
                    result.onNext("로그인 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "로그인 실패"))
    }
}
