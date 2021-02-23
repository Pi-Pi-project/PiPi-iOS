//
//  ProjectAPI.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/19.
//

import Foundation
import RxSwift
import RxCocoa

class ProjectAPI {
    let request = ServiceType()
    
    func getProject(_ page: String) -> Observable<([ProjectModel]?, networkingResult)> {
        request.requestDate(.getProject(page))
            .map { response, data -> ([ProjectModel]?, networkingResult) in
            switch response.statusCode {
            case 200:
                do {
                    let data = try JSONDecoder().decode([ProjectModel].self, from: data)
                    return (data, .ok)
                }catch{
                    print(error)
                }
                return (nil, .fault)
            default:
                return (nil, .fault)
            }
        }
    }
    
    func createTodo(_ todo: String, _ date: String, _ id: Int) -> Observable<networkingResult> {
        request.requestDate(.createTodo(todo, date, projectId: id))
            .map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func getTodo(_ id: Int, _ date: String) -> Observable<([todo]?, networkingResult)> {
        request.requestDate(.getTodo(id, date))
            .map { response, data -> ([todo]?, networkingResult)in
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode([todo].self, from: data) else { return (nil, .fault)}
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }
    
    func successTodo(_ id: Int) -> Observable<networkingResult> {
        request.requestDate(.successTodo(String(id)))
            .map { response, data -> networkingResult in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                return .ok
            case 404:
                return .notFound
            case 409:
                return .conflict
            default:
                return .fault
            }
        }
    }
    
    func finishProject(_ id: Int, _ giturl: String, _ introduce: String) -> Observable<networkingResult> {
        request.requestDate(.finishProject(id: id, giturl, introduce))
            .map { response, data -> networkingResult in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                return .ok
            case 404:
                return .notFound
            case 409:
                return .conflict
            default:
                return .fault
            }
        }
    }
    
    func getRoom() -> Observable<([room]?, networkingResult)> {
        request.requestDate(.getRoom)
            .map{ response, data ->  ([room]?, networkingResult) in
            switch response.statusCode{
            case 200:
                guard let data = try? JSONDecoder().decode([room].self, from: data) else { return (nil, .fault) }
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }
    
    func getChats(_ id: Int, _ page: Int) -> Observable<([getChat]?, networkingResult)> {
        request.requestDate(.getChats(id, page))
            .map{ response, data -> ([getChat]?, networkingResult) in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                do {
                    var data = try JSONDecoder().decode([getChat].self, from: data)
                    data.reverse()
                    return (data, .ok)
                }catch{
                    print(error)
                    
                    return (nil, .fault)
                }
            default:
                return (nil, .fault)
            }
        }
    }
    
}
