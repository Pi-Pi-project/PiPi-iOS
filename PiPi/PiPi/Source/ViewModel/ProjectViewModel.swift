//
//  ProjectViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/19.
//

import Foundation
import RxSwift
import RxCocoa

class ProjectViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    static var loadProject = PublishRelay<[ProjectModel]>()
    
    struct input {
        let loadProject: Signal<Void>
        let selectIndexPath: Driver<IndexPath>
    }
    
    struct output {
        let result: Signal<String>
        let detailProject: Signal<String>
    }
    
    func transform(_ input: input) -> output {
        let api = ProjectAPI()
        let result = PublishSubject<String>()
        let detailProject = PublishSubject<String>()
        let info = Driver.combineLatest(input.selectIndexPath, ProjectViewModel.loadProject.asDriver(onErrorJustReturn: []))
        
        input.loadProject.asObservable().subscribe(onNext: { _ in
            api.getProject("0").subscribe(onNext: { data, response in
                print(response)
                switch response {
                case .ok:
                    ProjectViewModel.loadProject.accept(data!)
                    result.onCompleted()
                default:
                    result.onNext("알 수 없는 오류")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.selectIndexPath.asObservable().withLatestFrom(info).subscribe(onNext: { indexPath, data in
            let data = data[indexPath.row].id
            detailProject.onNext(String(data))
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "진행 중인 프로젝트 로드 실패"), detailProject: detailProject.asSignal(onErrorJustReturn: ""))
    }
}
