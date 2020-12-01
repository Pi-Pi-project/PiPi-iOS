//
//  ChatListViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/29.
//

import Foundation
import RxSwift
import RxCocoa

class ChatListViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct input{
        let loadList: Signal<Void>
        let selectIndexPath: Signal<IndexPath>
    }
    
    struct output{
        let result: Signal<String>
        let loadList: PublishRelay<[room]>
        let room: Signal<Int>
    }
    
    func transform(_ input: input) -> output {
        let api = ProjectAPI()
        let result = PublishSubject<String>()
        let loadList = PublishRelay<[room]>()
        let room = PublishSubject<Int>()
        var select = Int()
        
        let info = Signal.combineLatest(input.selectIndexPath, loadList.asSignal())
            
        input.loadList.asObservable().subscribe(onNext:{ _ in
            api.getRoom().subscribe(onNext: { data, response in
                switch response{
                case .ok:
                    loadList.accept(data!)
                    result.onCompleted()
                default:
                    result.onNext("dad")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.selectIndexPath.asObservable().withLatestFrom(info).subscribe(onNext: { index, data in
            select = data[index.row].id
            room.onNext(select)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: ""), loadList: loadList, room: room.asSignal(onErrorJustReturn: 0))
    }
}
