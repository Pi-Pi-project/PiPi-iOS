//
//  MyPostViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/03.
//

import Foundation
import RxSwift
import RxCocoa

class MyPostViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    static var loadMyPost = BehaviorRelay<[postModel]>(value: [])
    
    struct input {
        let loadMyPost: Signal<Void>
        let selectMyPostRow: Signal<Int>
        let loadMoreData: Signal<Int>
    }
    
    struct output {
        let result: Signal<String>
        let detailView: Signal<String>
        let indexPath: Signal<String>
        let loadMoreData: BehaviorRelay<[postModel]>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
        let info = Signal.combineLatest(input.selectMyPostRow, MyPostViewModel.loadMyPost.asSignal(onErrorJustReturn: [])).asObservable()
        let detailView = PublishSubject<String>()
        var select = String()
        let loadMoreData = BehaviorRelay<[postModel]>(value: [])

        input.loadMyPost.asObservable().subscribe(onNext: { _ in
            api.getMyPost("0").subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    MyPostViewModel.loadMyPost.accept(response!)
                    result.onCompleted()
                default:
                    result.onNext("my post 불러오기 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.selectMyPostRow.asObservable().withLatestFrom(info).subscribe(onNext: { indexPath, data in
            select = String(data[indexPath].id)
            detailView.onNext(select)
        }).disposed(by: disposeBag)
        
        input.loadMoreData.asObservable().subscribe(onNext: { count in
            api.getMyPost("\(count)").subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    loadMoreData.accept(response!)
                default:
                    result.onNext("")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "get mypost 실패"), detailView: detailView.asSignal(onErrorJustReturn: "get mypost detail 실패"), indexPath: Signal.just(select), loadMoreData: loadMoreData)
    }
}
