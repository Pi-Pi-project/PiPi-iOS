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
        let showInfo: Signal<Void>
        let email: Signal<String>
        let loadData: Signal<Void>
        let loadMoreData: Signal<Int>
        let selectPostRow: Signal<IndexPath>
        let searchText: Driver<String>
        let loadMoreSearch: Driver<Int>
    }
    
    struct output {
        let result: Signal<String>
        let nextView: Signal<String>
        let data: Driver<[postModel]>
        let indexPath: Signal<String>
        let searchResult: Signal<String>
        let loadData: BehaviorRelay<[postModel]>
        let loadMoreData: BehaviorRelay<[postModel]>
        let loadMoreSearch: BehaviorRelay<[postModel]>
        let likePost: BehaviorRelay<[postModel]>
        let like: Signal<String>
        let email: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = PostAPI()
        let load = ProfileAPI()
        let result = PublishSubject<String>()
        let like = PublishSubject<String>()
        let emailResult = PublishSubject<String>()
        let searchResult = PublishSubject<String>()
        let nextView = PublishSubject<String>()
        let loadData = BehaviorRelay<[postModel]>(value: [])
        let loadMoreData = BehaviorRelay<[postModel]>(value: [])
        let loadMoreSearch = BehaviorRelay<[postModel]>(value: [])
        let likePost = BehaviorRelay<[postModel]>(value: [])
        let info = Signal.combineLatest(input.selectPostRow, loadData.asSignal(onErrorJustReturn: [])).asObservable()
        var select = String()
        let categoty = Driver.combineLatest(input.searchText, input.loadMoreSearch)
        let email = PublishRelay<String>()
        
        input.showInfo.asObservable().subscribe(onNext: { _ in
            load.showUserInfo().subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    print("email받음")
                    emailResult.onNext(data!.email)
//                    email = data!.email
                default:
                    result.onNext("프로필 로드 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.email.asObservable().subscribe(onNext: { email in
            print("vm \(email)")
            api.emailOutput(email).subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    print(response)
                    likePost.accept(response!)
                    like.onCompleted()
                default:
                    result.onNext("프로필 로드 실패")
                }
            }).disposed(by: self.disposeBag)

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
        
        input.loadMoreSearch.withLatestFrom(categoty).asObservable().subscribe(onNext: { cate, page in
            api.searchPost(cate, page).subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    loadMoreSearch.accept(response!)
                default:
                    print(statusCode)
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "get post 실패"),
                      nextView: nextView.asSignal(onErrorJustReturn: "get detail post 실패"),
                      data: loadData.asDriver(onErrorJustReturn: []),
                      indexPath: Signal.just(select),
                      searchResult: searchResult.asSignal(onErrorJustReturn: "search 실패"), loadData: loadData,
                      loadMoreData: loadMoreData,
                      loadMoreSearch: loadMoreSearch,
                      likePost: likePost, like: like.asSignal(onErrorJustReturn: ""),
                      email: emailResult.asSignal(onErrorJustReturn: ""))
    }
}
