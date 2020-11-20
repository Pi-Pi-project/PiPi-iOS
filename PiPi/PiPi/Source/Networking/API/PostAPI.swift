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
    let baseURL = "http://15.164.245.146"
    
    func formDataPost(_ api: PiPiAPI, param: Parameters, img: Data?) -> DataRequest {
        return AF.upload(multipartFormData: { (multipartFormData) in
            
            if img != nil {
                multipartFormData.append(img!, withName: "img", mimeType: "image/jpg")
            }
            
            for (key, value) in param { multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
            }
        }, to: baseURL + api.path(), method: .post, headers: api.header())
    }
    
    func getPosts() -> Observable<([postModel]?, networkingResult)> {
        httpClient.get(.getPost(1), param: nil).map { response, data -> ([postModel]?, networkingResult) in
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
    
    func getApplyPosts() -> Observable<([postModel]?, networkingResult)> {
        httpClient.get(.getApplyPosts("1"), param: nil).map { response, data -> ([postModel]?, networkingResult) in
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
    
    func getMyPost() -> Observable<([postModel]?, networkingResult)> {
        httpClient.get(.getMyPost, param: nil).map { response, data -> ([postModel]?, networkingResult) in
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

    
}
