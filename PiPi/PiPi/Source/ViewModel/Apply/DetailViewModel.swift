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
    private let disposeBag = DisposeBag()
    
    struct input {
        let loadDetail: Signal<Void>
        let selectIndexPath: String
        let selectApply: Driver<Void>
    }
    
    struct output {
        let loadDetail: PublishRelay<detailModel>
        let resultLoad: Signal<String>
        let resultApplyT: Driver<String>
        let resultApplyF: Driver<String>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
        let loadDetail = PublishRelay<detailModel>()
        let resultApplyT = PublishSubject<String>()
        let resultApplyF = PublishSubject<String>()
        let info = Signal.combineLatest(input.selectApply.asSignal(onErrorJustReturn: ()), loadDetail.asSignal())
        
        input.loadDetail.asObservable().subscribe(onNext: {[weak self] id in
            guard let self = self else {return}
            api.getDetailPost(input.selectIndexPath).subscribe(onNext: { response,statusCode in
                switch statusCode {
                case .ok:
                    loadDetail.accept(response!)
                    result.onCompleted()
                default:
                    result.onNext("디테일 포스트 로드 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.selectApply.asObservable().withLatestFrom(info).subscribe(onNext: {[weak self] selectApply, data in
            guard let self = self else {return}
            if !data.applied {
                api.postProjectApply(input.selectIndexPath).subscribe(onNext: { response in
                    print("postApply \(response)")
                    switch response {
                    case .ok:
                        return resultApplyT.onCompleted()
                    default:
                        return resultApplyT.onNext("프로젝트 신청 실패")
                    }
                }).disposed(by: self.disposeBag)
            }else {
                api.deleteProjectApply(input.selectIndexPath).subscribe(onNext: { response in
                    print("depostApply \(response)")
                    switch response {
                    case .ok:
                        return resultApplyF.onCompleted()
                    case .notFound:
                        return resultApplyF.onNext("post not founc")
                    default:
                        return resultApplyF.onNext("프로젝트 취소 실패")
                    }
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        return output(loadDetail: loadDetail, resultLoad: result.asSignal(onErrorJustReturn: "get detail 실패"), resultApplyT: resultApplyT.asDriver(onErrorJustReturn: "post apply 실패"), resultApplyF: resultApplyF.asDriver(onErrorJustReturn: "delete apply 실패"))
    }
}
