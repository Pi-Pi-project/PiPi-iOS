//
//  DetailViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/03.
//

import Foundation
import RxSwift
import RxCocoa

class DetailViewModel: ViewModelType {
    static var loadDetail = PublishRelay<detailModel>()
    private let disposeBag = DisposeBag()
    
    struct input {
        let loadDetail: Signal<Void>
        let selectIndexPath: String
    }
    
    struct output {
        let result: Signal<String>
        let isApply: Driver<Bool>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
//        let info = Signal.combineLatest(input.selectIndexPath, MainViewModel.loadData.asSignal()).asObservable()
        let isApply = PublishSubject<Bool>()
        
        input.loadDetail.asObservable().subscribe(onNext: { id in
            api.getDetailPost(input.selectIndexPath).subscribe(onNext: { response,statusCode in
                print(statusCode)
                switch statusCode {
                case .ok:
                    DetailViewModel.loadDetail.accept(response!)
                    
                    result.onCompleted()
                default:
                    result.onNext("디테일 포스트 로드 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "get detail 실패"), isApply: isApply.asDriver(onErrorJustReturn: false))
    }
}
