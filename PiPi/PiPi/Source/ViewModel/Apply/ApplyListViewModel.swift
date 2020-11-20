//
//  ApplyListViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/04.
//

import Foundation
import RxSwift
import RxCocoa

class ApplyListViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    static var loadApplyList = PublishRelay<[ApplyList]>()
    
    struct input {
        let loadApplyData: Signal<Void>
        let selectApplyList: String
        let selectIndexPath: Signal<Int>
        let selectAccept: Signal<Void>
        let selectReject: Signal<Void>
    }
    
    struct output {
        let result: Signal<String>
        let accept: Signal<Bool>
        let reject: Signal<Bool>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
        let isAccept = PublishSubject<Bool>()
        let isReject = PublishSubject<Bool>()
        let info = Signal.combineLatest(input.selectIndexPath, ApplyListViewModel.loadApplyList.asSignal())
        
        input.loadApplyData.asObservable().subscribe(onNext: { _ in
            print(input.selectApplyList)
            api.getApplyList(input.selectApplyList).subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    ApplyListViewModel.loadApplyList.accept(response!)
                    return result.onCompleted()
                default:
                    return result.onNext("신청자 목록 로드 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.selectIndexPath.asObservable().withLatestFrom(info).subscribe(onNext: { row, data in
            if data[row].status != "ACCEPTED"{
                api.postAcceptApply(data[row].userEmail, input.selectApplyList).subscribe(onNext: { statusCode in
                    switch statusCode {
                    case .ok:
                        return isAccept.onCompleted()
                    default:
                        return isAccept.onNext(false)
                    }
                }).disposed(by: self.disposeBag)
            }else {
                api.deleteRejectApply(data[row].userEmail, input.selectApplyList).subscribe(onNext: { statusCode in
                    switch statusCode {
                    case .ok:
                        return isReject.onCompleted()
                    default:
                        return isReject.onNext(false)
                    }
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        input.selectReject.asObservable().withLatestFrom(info).subscribe(onNext: { row, data in
            api.deleteRejectApply(data[row].userEmail, input.selectApplyList).subscribe(onNext: { statusCode in
                switch statusCode {
                case .ok:
                    return isReject.onCompleted()
                default:
                    return isReject.onNext(false)
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "get apply list 실패"), accept: isAccept.asSignal(onErrorJustReturn: false), reject: isReject.asSignal(onErrorJustReturn: false))
        
    }
}
