//
//  SetProfileViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/01.
//

import Foundation
import RxSwift
import RxCocoa

class SetProfileViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    
    struct input {
        let userImage: Driver<String?>
        let userSkill: Driver<[String]>
        let userGit: Driver<String>
        let userEmail: Driver<String>
        let doneTap: Signal<Void>
    }
    
    struct  output {
        let result: Signal<String>
        let isEnable: Driver<Bool>
    }
    
    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let result = PublishSubject<String>()
        let info = Driver.combineLatest(input.userSkill, input.userGit, input.userEmail, input.userImage)
        let isEnable = info.map { !$0.0.isEmpty && !$0.1.isEmpty }
        
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { userS, userG, userE, userI in
            api.setProfile(userE, skils: userS, gitURL: userG, userImg: userI!).subscribe(onNext: { response in
                switch response {
                case .ok1:
                    return result.onCompleted()
                default:
                    return result.onNext("가입이 되지 않음")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "프로필 설정 실패"), isEnable: isEnable.asDriver())
    }
}
