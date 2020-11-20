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
    
    struct input {
        let profileUser: Driver<String>
        let loadProfile: Signal<Void>
//        let eidtTap: Signal<Void>
//        let changePwTap: Signal<Void>
    }
    
    struct output {
        let result: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let result = PublishSubject<String>()
        
        input.loadProfile.asObservable().subscribe(onNext: { _ in
            api.getProfile("a@gmail.com").subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    SeeProfileViewModel.loadProfile.accept(data!)
                    result.onCompleted()
                default:
                    result.onNext("프로필 로드 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "getProfile 실패"))
    }
}
