//
//  CalendarViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/19.
//

import Foundation
import RxSwift
import RxCocoa

class CalendarViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    static var loadTodo = PublishRelay<[todo]>()
    
    struct input{
        let selectIndexPath: Driver<Int>
        let selectDate: Driver<String>
        let todoText: Driver<String>
        let alertTap: Driver<Void>
        let successTodo: Driver<Int>
    }
    
    struct output{
        let result: Signal<String>
        let success: Signal<String>
        let todo: Signal<String>
        let enter: Signal<String>
    }
    
    func transform(_ input : input) -> output {
        let api = ProjectAPI()
        let result = PublishSubject<String>()
        let success = PublishSubject<String>()
        let enter = PublishSubject<String>()
        let info = Driver.combineLatest(input.selectIndexPath, input.selectDate)
        let todoInfo = Driver.combineLatest(input.selectIndexPath, input.todoText, input.selectDate)
        let successTodo = Driver.combineLatest(input.successTodo, CalendarViewModel.loadTodo.asDriver(onErrorJustReturn: []))
        
        input.selectDate.asObservable().withLatestFrom(info).subscribe(onNext: {[weak self] id, date in
            guard let self = self else {return}
            api.getTodo(id, date).subscribe(onNext: { data, response in
                switch response {
                case .ok:
                    CalendarViewModel.loadTodo.accept(data!)
                    result.onCompleted()
                default:
                    result.onNext("todolist 가져오기 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.alertTap.asObservable().withLatestFrom(todoInfo).subscribe(onNext: {[weak self] id, todo, date in
            guard let self = self else {return}
            api.createTodo(todo, date, id).subscribe(onNext: { response in
                switch response {
                case .ok:
                    enter.onNext("^^")
                default:
                    print("todo fault")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        input.successTodo.asObservable().withLatestFrom(successTodo).subscribe(onNext: {[weak self] id, data in
            guard let self = self else {return}
            let todoId = data[id].id
            api.successTodo(todoId).subscribe(onNext: { response in
                switch response {
                case .ok:
                    success.onNext("todo 완료")
                default:
                    success.onNext("tood 완료 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: "todolist 가져오기 실패"), success: success.asSignal(onErrorJustReturn: "todo 완료 실패"), todo: enter.asSignal(onErrorJustReturn: "todo load 실패"), enter: enter.asSignal(onErrorJustReturn: "todo 올리기 실패"))
    }
}
