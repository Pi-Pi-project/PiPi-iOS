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
    static var loadMyPost = PublishRelay<[postModel]>()
    
    struct input {
        let loadMyPost: Signal<Void>
        let selectMyPostRow: Signal<IndexPath>
    }
    
    struct output {
        let result: Signal<String>
        let detailView: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
        let info = Signal.combineLatest(input.selectMyPostRow, MyPostViewModel.loadMyPost.asSignal()).asObservable()
        let detailView = PublishSubject<String>()
        var select = String()
        
        input.loadMyPost.asObservable().subscribe(onNext: { _ in
            api.getMyPost().subscribe(onNext: { response, statusCode in
                print(statusCode)
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
            select = String(data[indexPath.row].id)
            detailView.onNext(select)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "get mypost 실패"), detailView: detailView.asSignal(onErrorJustReturn: "get mypost detail 실패"))
    }
}
