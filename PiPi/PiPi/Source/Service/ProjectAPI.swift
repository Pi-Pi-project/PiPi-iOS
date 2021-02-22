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
    let httpClient = HTTPClient()
    
    func getProject(_ page: String) -> Observable<([ProjectModel]?, networkingResult)> {
        httpClient.get(.getProject(page), param: nil).map { response, data -> ([ProjectModel]?, networkingResult) in
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
        httpClient.post(.createTodo, param: ["todo": todo, "date": date, "projectId": id]).catchError{ error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://10.156.145.141:8080")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func getTodo(_ id: Int, _ date: String) -> Observable<([todo]?, networkingResult)> {
        httpClient.get(.getTodo(id, date), param: nil).catchError{ error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://10.156.145.141:8080")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map { response, data -> ([todo]?, networkingResult)in
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
        httpClient.put(.successTodo(String(id)), param: nil).catchError{ error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://10.156.145.141:8080")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map { response, data -> networkingResult in
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
        httpClient.put(.finishProject, param: ["id": id, "giturl": giturl, "introduce": introduce]).catchError{ error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://10.156.145.141:8080")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map { response, data -> networkingResult in
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
        httpClient.get(.getRoom, param: nil).map{ response, data ->  ([room]?, networkingResult) in
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
        httpClient.get(.getChats(id, page), param: nil).map{ response, data -> ([getChat]?, networkingResult) in
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
