//
//  PorfolioViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/15.
//

import Foundation
import RxSwift
import RxCocoa

class PortfolioViewModel: ViewModelType {
    private let dispoeBag = DisposeBag()
    
    static var loadPortfolio = PublishRelay<[portfolio]>()
    
    struct input {
        let loadPortfolio: Signal<Void>
        let firstPortfolio: Driver<Int?>
        let secondPortfolio: Driver<Int?>
        let doneTap: Driver<Void>
        let addTap: Driver<Void>
    }
    
    struct output {
        let result: Signal<String>
        let doneResult: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let result = PublishSubject<String>()
        let doneInfo = Driver.combineLatest(input.firstPortfolio, input.secondPortfolio, PortfolioViewModel.loadPortfolio.asDriver(onErrorJustReturn: []))
        let doneResult = PublishSubject<String>()
        
        //folio indexpath.row 받아서 그거 first랑 second 보내기
        
        input.loadPortfolio.asObservable().subscribe(onNext: { _ in
            api.getPortfolios("a@gmail.com").subscribe(onNext: { data, response in
                print(response)
                switch response {
                case .ok:
                    PortfolioViewModel.loadPortfolio.accept(data!)
                    result.onCompleted()
                default:
                    result.onNext("포트폴리오 로드 실패")
                }
            }).disposed(by: self.dispoeBag)
        }).disposed(by: dispoeBag)
        
        input.doneTap.asObservable().withLatestFrom(doneInfo).subscribe(onNext: { firstPortfolio, secondPortfolio, data in
            let firstId = String(data[firstPortfolio ?? 0].id)
            let secondId = String(data[secondPortfolio ?? 0].id)
            api.selectPortfolio(firstId, secondId).subscribe(onNext: { response in
                switch response {
                case .ok:
                    print("ok")
                    doneResult.onCompleted()
                case .notFound:
                    doneResult.onNext("찾을 수 있는 프로젝트 목록이 없음")
                default:
                    doneResult.onNext("지정된 프로젝트가 없음")
                }
            }).disposed(by: self.dispoeBag)
        }).disposed(by: dispoeBag
        )
        return output(result: result.asSignal(onErrorJustReturn: ""), doneResult: doneResult.asSignal(onErrorJustReturn: "포트폴리오 목록 수정 실패"))
    }
}
