//
//  ChatViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/30.
//

import Foundation
import RxSwift
import RxCocoa

class ChatViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    
    struct input {
        let showEmail: Signal<Void>
        let loadChat: Signal<Void>
        let roomId: Int
        let loadMoreChat: Signal<Int>
    }
    
    struct output {
        let result: Signal<String>
        let loadChat: BehaviorRelay<[getChat]>
        let refresh: PublishRelay<[getChat]>
    }
    
    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let load = ProjectAPI()
        let result = PublishSubject<String>()
        let loadChat = BehaviorRelay<[getChat]>(value: [])
        let chat = PublishSubject<String>()
        let refresh = PublishRelay<[getChat]>()
        let info = input.roomId
        
        input.showEmail.asObservable().subscribe(onNext: { _ in
            api.showUserInfo().subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    result.onNext(data!.email)
                default:
                    print(data!)
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.loadChat.asObservable().subscribe(onNext: { _ in
            load.getChats(input.roomId, 0).subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    loadChat.accept(data!)
                    chat.onCompleted()
                default:
                    chat.onNext("")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.loadMoreChat.asObservable().subscribe(onNext: { page in
            load.getChats(input.roomId, page).subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    refresh.accept(data!)
                default:
                    print(response)
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        return output(result: result.asSignal(onErrorJustReturn: ""), loadChat: loadChat, refresh: refresh)
    }
}
