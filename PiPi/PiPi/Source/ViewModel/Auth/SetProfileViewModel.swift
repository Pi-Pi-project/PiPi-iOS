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
        let userImage: Driver<Data?>
        let userSkill: Driver<[String]?>
        let userGit: Driver<String?>
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
        let isEnable = info.map { !$0.0!.isEmpty }
        
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { userS, userG, userE, userI in
            api.setProfile(.setProfile, param: ["email": "3981288@gmail.com", "skills": userS ?? [],"giturl": userG ?? ""], img: userI).responseJSON { (response) in
                print(response.response?.statusCode)
                switch response.response?.statusCode {
                case 200:
                    result.onCompleted()
                default:
                    result.onNext("프로필 수정 실패")
                }
            }
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "프로필 설정 실패"), isEnable: isEnable.asDriver())
    }
}
