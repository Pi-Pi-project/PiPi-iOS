//
//  ProjectAPI.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import Foundation
import RxSwift
import Alamofire

class PostAPI{
    
    let httpClient = HTTPClient()
    let baseURL = "http://3.35.216.218"
    
    func createProject(_ id: String) -> Observable<networkingResult> {
        httpClient.post(.createProject, param: ["postId": id]).map { response, data -> networkingResult in
            switch response.statusCode{
            case 200:
                return .ok
            case 409:
                return .conflict
            default:
                return .fault
            }
        }
    }
    
    func formDataPost(_ api: PiPiAPI, param: Parameters, img: Data?) -> DataRequest {
        return AF.upload(multipartFormData: { (multipartFormData) in
            if img != nil {
                multipartFormData.append(img!, withName: "img", fileName: "image.jpg", mimeType: "image/jpg")
            }
            for (key, value) in param {
                if key == "skills" {
                    let arrayObj = value as! Array<Any>
                    for i in 0..<arrayObj.count {
                        let value = arrayObj[i] as! String
                        print("\(key) \(value)")
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                }else {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
                }
            }
        }, to: baseURL + api.path(), method: .post, headers: api.header())
    }
    
    func getPosts(_ page: Int) -> Observable<([postModel]?, networkingResult)> {
        httpClient.get(.getPost(page), param: nil).map { response, data -> ([postModel]?, networkingResult) in
            print("get post \(response.statusCode)")
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode([postModel].self, from: data) else { return (nil, .fault)}
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }
    
    func getApplyPosts(_ page: String) -> Observable<([postModel]?, networkingResult)> {
        httpClient.get(.getApplyPosts(page), param: nil).map { response, data -> ([postModel]?, networkingResult) in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode([postModel].self, from: data) else { return (nil, .fault)}
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }

    func getDetailPost(_ id: String) -> Observable<(detailModel?, networkingResult)> {
        httpClient.get(.getDetailPost(id), param: nil).map { response, data -> (detailModel?, networkingResult) in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                guard let data  = try? JSONDecoder().decode(detailModel.self, from: data) else {return (nil, .fault)}
                print(data)
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }

    func postProjectApply(_ id: String) -> Observable<networkingResult> {
        httpClient.post(.projectApply, param: ["id": id])
            .catchError{ error -> Observable<(HTTPURLResponse, Data)> in
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
            case 404:
                return .notFound
            default:
                return .fault
            }
        }
    }

    func deleteProjectApply(_ id: String) -> Observable<networkingResult> {
        httpClient.delete(.deProjectApply, param: ["id" : id])
            .catchError{ error -> Observable<(HTTPURLResponse, Data)> in
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
            case 404:
                return .notFound
            default:
                return .fault
            }
        }
    }
    
    func getApplyList(_ id: String) -> Observable<([ApplyList]?, networkingResult)> {
        httpClient.get(.getApplyList(id), param: nil).map { response, data -> ([ApplyList]?, networkingResult) in
            print(data)
            switch response.statusCode {
            case 200:
                print(response.statusCode)
                guard let data = try? JSONDecoder().decode([ApplyList].self, from: data) else { return (nil, .fault)}
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }

    func deleteRejectApply(_ userEmail: String, _ postID: String) -> Observable<networkingResult> {
        httpClient.put(.rejectApply, param: ["userEmail": userEmail, "postId": postID])
            .catchError{ error -> Observable<(HTTPURLResponse, Data)> in
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

    func postAcceptApply(_ userEmail: String, _ postID: String) -> Observable<networkingResult> {
        httpClient.put(.acceptApply, param: ["userEmail": userEmail, "postId":postID])
            .catchError{ error -> Observable<(HTTPURLResponse, Data)> in
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
    
    func getMyPost(_ page: String) -> Observable<([postModel]?, networkingResult)> {
        httpClient.get(.getMyPost(page), param: nil).map { response, data -> ([postModel]?, networkingResult) in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode([postModel].self, from: data) else { return (nil, .fault)}
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }
    
    func searchPost(_ category: String,_ page: Int) -> Observable<([postModel]?, networkingResult)> {
        httpClient.get(.searchPost(category, page), param: nil).map{ response,data -> ([postModel]?, networkingResult) in
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode([postModel].self, from: data) else { return (nil, .fault) }
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }

    func getIndividualChat(_ email: String) -> Observable<(roomId?, networkingResult)> {
        httpClient.get(.getIndividualCaht(email), param: nil).map{ (response, data) -> (roomId?, networkingResult) in
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode(roomId.self, from: data) else { return (nil, .fault)}
                
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }
    
    func emailOutput(_ email: String) -> Observable<([postModel]?, networkingResult)> {
        httpClient.aiPost(.output, param: ["email": email]).map { response, data -> ([postModel]?, networkingResult) in
            print(response.statusCode)
            print("api \(email)")
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode([postModel].self, from: data) else { return (nil, .fault)}
                
                return (data, .ok)
            default:
                print(response.statusCode)
                return (nil, .fault)
            }
        }
    }
}
