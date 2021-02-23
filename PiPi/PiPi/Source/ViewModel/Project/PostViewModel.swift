//
//  PostViewModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/05.
//

import Foundation
import RxSwift
import RxCocoa

class PostViewModel: ViewModelType {
    private let disposeBag = DisposeBag()

    struct input {
        let title: Driver<String>
        let category: Driver<String>
        let skills: Driver<[String]>
        let idea: Driver<String>
        let content: Driver<String>
        let max: Driver<Double>
        let img: Driver<Data?>
        let postTap: Signal<Void>
    }

    struct output {
        let result: Signal<String>
        let isEnable: Driver<Bool>
    }

    func transform(_ input: input) -> output {
        let api = PostAPI()
        let info = Driver.combineLatest(
            input.title,
            input.category,
            input.skills,
            input.idea,
            input.content,
            input.max,
            input.img)
        let isEnabel = info.map {
            !$0.0.isEmpty &&
                !$0.1.isEmpty &&
                !$0.3.isEmpty &&
                !$0.4.isEmpty }
        
        let result = PublishSubject<String>()
        
        input.postTap.withLatestFrom(info).asObservable().subscribe(onNext: {
            title, category, skills, idea, content, max, img in
            
            api.formDataPost(.wirtePost, param: ["title": title, "category": category, "skills": skills, "idea": idea, "content": content, "max": Int(max)], img: img ?? nil).responseJSON { (response) in
                switch response.response?.statusCode {
                case 200:
                    print("success")
                    result.onCompleted()
                default:
                    print(response.response?.statusCode ?? "fault")
                    result.onNext("post 올리기 실패 \(response.response?.statusCode ?? 600)")
                }
            }
        }).disposed(by: disposeBag)

        
        return output(result: result.asSignal(onErrorJustReturn: "post 실패"), isEnable: isEnabel.asDriver())
    }
}
