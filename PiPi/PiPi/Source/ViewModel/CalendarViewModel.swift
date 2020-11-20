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
    }
    
    struct output{
        let result: Signal<String>
    }
    
    func transform(_ input : input) -> output {
        let api = ProjectAPI()
        let result = PublishSubject<String>()
        let info = Driver.combineLatest(input.selectIndexPath, input.selectDate)
        let todoInfo = Driver.combineLatest(input.selectIndexPath, input.todoText, input.selectDate)
            
        input.selectDate.asObservable().withLatestFrom(info).subscribe(onNext: { id, date in
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
        
        input.alertTap.asObservable().withLatestFrom(todoInfo).subscribe(onNext: { id, todo, date in
            api.createTodo(todo, date, id).subscribe(onNext: { response in
                print("createTodo")
                print(id)
                print(todo)
                print(date)
                print(response)
                switch response {
                case .ok:
                    print("todo success")
                default:
                    print("todo fault")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        return output(result: result.asSignal(onErrorJustReturn: "todolist 가져오기 실패"))
    }
}
