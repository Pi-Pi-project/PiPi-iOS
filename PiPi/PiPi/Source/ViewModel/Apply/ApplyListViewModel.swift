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
        let createProject: Driver<Void>
        let goToChat: Signal<Int>
    }
    
    struct output {
        let result: Signal<String>
        let accept: Signal<Bool>
        let reject: Signal<Bool>
        let create: Signal<String>
        let goChat: Signal<Int>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
        let create = PublishSubject<String>()
        let isAccept = PublishSubject<Bool>()
        let isReject = PublishSubject<Bool>()
        let goChat = PublishSubject<Int>()
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
                        return isAccept.onNext(true)
                    default:
                        return isAccept.onCompleted()
                    }
                }).disposed(by: self.disposeBag)
            }else {
                api.deleteRejectApply(data[row].userEmail, input.selectApplyList).subscribe(onNext: { statusCode in
                    switch statusCode {
                    case .ok:
                        return isReject.onNext(true)
                    default:
                        return isReject.onCompleted()
                    }
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        input.createProject.asObservable().withLatestFrom(info).subscribe(onNext: { row, data in
            api.createProject(input.selectApplyList).subscribe(onNext: { response in
                switch response {
                case .ok:
                    create.onCompleted()
                case .conflict:
                    create.onNext("인원을 초과하였습니다.")
                default:
                    create.onNext("프로젝트 만들기 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.goToChat.asObservable().withLatestFrom(info).subscribe(onNext:{ row, data in
            api.getIndividualChat(data[row].userEmail).subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    goChat.onNext(data!.roomId)
                default:
                    goChat.onCompleted()
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "get apply list 실패"), accept: isAccept.asSignal(onErrorJustReturn: false), reject: isReject.asSignal(onErrorJustReturn: false), create: create.asSignal(onErrorJustReturn: "create project 실패"), goChat: goChat.asSignal(onErrorJustReturn: 0))
    }
}
