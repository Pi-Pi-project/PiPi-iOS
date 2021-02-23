//
//  SeeProfileViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/13.
//

import Foundation
import RxSwift
import RxCocoa

class SeeProfileViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    static var loadProfile = PublishRelay<profileModel>()
    static var email = PublishRelay<String>()
    
    struct input {
        let profileUser: Driver<String>
        let loadProfile: Signal<Void>
        let showInfo: Signal<Void>
    }
    
    struct output {
        let result: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let result = PublishSubject<String>()
        let info = input.profileUser
        
        input.showInfo.asObservable().subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            api.showUserInfo().subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    SeeProfileViewModel.email.accept(data!.email)
                    result.onCompleted()
                default:
                    result.onNext("프로필 로드 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.loadProfile.withLatestFrom(info).asObservable().subscribe(onNext: {[weak self] email in
            guard let self = self else { return }
            api.getProfile(email).subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    SeeProfileViewModel.loadProfile.accept(data!)
                default:
                    result.onNext("프로필 가져오기 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "getProfile 실패"))
    }
}
