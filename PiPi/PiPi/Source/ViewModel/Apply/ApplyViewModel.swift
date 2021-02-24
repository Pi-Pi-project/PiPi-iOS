//
//  ApplyViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/03.
//

import Foundation
import RxSwift
import RxCocoa

class ApplyViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    static var loadApplyData = BehaviorRelay<[postModel]>(value: [])
    
    struct input {
        let loadData: Signal<Void>
        let selectApplyRow: Signal<IndexPath>
        let loadMoreData: Signal<Int>
    }
    
    struct output {
        let detailView: Signal<String>
        let result: Signal<String>
        let loadMoreData: BehaviorRelay<[postModel]>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
        let info = Signal.combineLatest(input.selectApplyRow, ApplyViewModel.loadApplyData.asSignal(onErrorJustReturn: [])).asObservable()
        let detailView = PublishSubject<String>()
        var select = String()
        let loadMoreData = BehaviorRelay<[postModel]>(value: [])
        
        input.loadData.asObservable().subscribe(onNext: {[weak self] _ in
            guard let self = self else {return}
            api.getApplyPosts("0").subscribe(onNext: { response, statusCode in
                print(statusCode)
                switch statusCode {
                case .ok:
                    ApplyViewModel.loadApplyData.accept(response!)
                    result.onCompleted()
                default:
                    result.onNext("신청 목록 불러오기 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.selectApplyRow.asObservable().withLatestFrom(info).subscribe(onNext: { indexPath, data in
            select = String(data[indexPath.row].id)
            detailView.onNext(select)
        }).disposed(by: disposeBag)
        
        input.loadMoreData.asObservable().subscribe(onNext: {[weak self] count in
            guard let self = self else {return}
            api.getApplyPosts("\(count)").subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    loadMoreData.accept(response!)
                default:
                    result.onNext("")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(detailView: detailView.asSignal(onErrorJustReturn: "get apply detail 실패"), result: result.asSignal(onErrorJustReturn: "get apply 실패"), loadMoreData: loadMoreData)
    }
}
