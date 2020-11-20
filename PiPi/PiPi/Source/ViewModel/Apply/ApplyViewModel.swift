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
    static var loadApplyData = PublishRelay<[postModel]>()
    
    struct input {
        let loadData: Signal<Void>
        let selectApplyRow: Signal<IndexPath>
    }
    
    struct output {
        let detailView: Signal<String>
        let result: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
        let info = Signal.combineLatest(input.selectApplyRow, ApplyViewModel.loadApplyData.asSignal()).asObservable()
        let detailView = PublishSubject<String>()
        var select = String()
        
        input.loadData.asObservable().subscribe(onNext: { _ in
            api.getApplyPosts().subscribe(onNext: { response, statusCode in
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
        
        return output(detailView: detailView.asSignal(onErrorJustReturn: "get apply detail 실패"), result: result.asSignal(onErrorJustReturn: "get apply 실패"))
    }
}
