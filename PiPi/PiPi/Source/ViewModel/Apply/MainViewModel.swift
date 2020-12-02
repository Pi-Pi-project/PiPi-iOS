//
//  MainViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import Foundation
import RxSwift
import RxCocoa

class MainViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct input {
        let loadData: Signal<Void>
        let loadMoreData: Signal<Int>
        let selectPostRow: Signal<IndexPath>
        let searchText: Driver<String>
    }
    
    struct output {
        let result: Signal<String>
        let nextView: Signal<String>
        let data: Driver<[postModel]>
        let indexPath: Signal<String>
        let searchResult: Signal<String>
        let loadData: BehaviorRelay<[postModel]>
        let loadMoreData: BehaviorRelay<[postModel]>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let result = PublishSubject<String>()
        let searchResult = PublishSubject<String>()
        let nextView = PublishSubject<String>()
        let loadData = BehaviorRelay<[postModel]>(value: [])
        let loadMoreData = BehaviorRelay<[postModel]>(value: [])
        let info = Signal.combineLatest(input.selectPostRow, loadData.asSignal(onErrorJustReturn: [])).asObservable()
        var select = String()
        
        input.loadData.asObservable().subscribe(onNext: { _ in
            api.getPosts(0).subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    loadData.accept(response!)
                    result.onCompleted()
                default:
                    result.onNext("포스트 불러오기 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.loadMoreData.asObservable().subscribe(onNext: { count in
            api.getPosts(count).subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    loadMoreData.accept(response!)
                default:
                    result.onNext("")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.selectPostRow.asObservable().withLatestFrom(info).subscribe(onNext: { indexPath, data in
            select = String(data[indexPath.row].id)
            nextView.onNext(select)
        }).disposed(by: disposeBag)
        
        input.searchText.asObservable().subscribe(onNext: { searchText in
            api.searchPost(searchText, 0).subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    loadData.accept(response!)
                    searchResult.onCompleted()
                default:
                    searchResult.onNext("검색 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "get post 실패"),
                      nextView: nextView.asSignal(onErrorJustReturn: "get detail post 실패"),
                      data: loadData.asDriver(onErrorJustReturn: []),
                      indexPath: Signal.just(select),
                      searchResult: searchResult.asSignal(onErrorJustReturn: "search 실패"), loadData: loadData,
                      loadMoreData: loadMoreData)
    }
}
