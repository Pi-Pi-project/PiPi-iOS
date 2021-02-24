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
        let showEmail: Driver<Void>
        let userImage: Driver<Data?>
        let userSkill: Driver<[String]?>
        let userGit: Driver<String?>
        let userEmail: Driver<String>
        let userIntro: Driver<String?>
        let doneTap: Signal<Void>
    }
    
    struct  output {
        let result: Signal<String>
        let isEnable: Driver<Bool>
        let email: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let show = ProfileAPI()
        let result = PublishSubject<String>()
        let email = PublishSubject<String>()
        let info = Driver.combineLatest(input.userSkill, input.userGit, input.userEmail, input.userImage, input.userIntro)
        let isEnable = info.map { !$0.0!.isEmpty }
        
        input.showEmail.asObservable().subscribe(onNext: {[weak self] _ in
            guard let self = self else {return}
            show.showUserInfo().subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    email.onNext(data!.email)
                default:
                    print(data!)
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { userS, userG, userE, userI, userIntro in
            api.setProfile(.setProfile, param: ["email": userE, "skills": userS ?? [],"giturl": userG ?? "", "introduce": userIntro ?? ""], img: userI).responseJSON { (response) in
                print(response)
                switch response.response?.statusCode {
                case 200:
                    result.onCompleted()
                default:
                    result.onNext("프로필 수정 실패")
                }
            }
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "프로필 설정 실패"), isEnable: isEnable.asDriver(), email: email.asSignal(onErrorJustReturn: "get email 실패"))
    }
}
