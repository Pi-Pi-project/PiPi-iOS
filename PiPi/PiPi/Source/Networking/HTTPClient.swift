//
//  HTTPClient.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import RxAlamofire
import RxSwift
import Alamofire

class HTTPClient {
    
    let baseURL = "http://15.164.245.146"
    
    typealias httpResult = Observable<(HTTPURLResponse, Data)>
    
    func get(_ api: PiPiAPI, param: Parameters?) -> httpResult {
        return requestData(.get, baseURL + api.path(),
                           parameters: param,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.header())
    }
    
    func post(_ api: PiPiAPI, param: Parameters?, encoding: ParameterEncoding = JSONEncoding.default) -> httpResult {
        return requestData(.post, baseURL + api.path(),
                           parameters: param,
                           encoding: encoding,
                           headers: api.header())
    }
    
    func put(_ api: PiPiAPI, param: Parameters?) -> httpResult {
        return requestData(.put, baseURL + api.path(),
                           parameters: param,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.header())
    }
    
    func delete(_ api: PiPiAPI, param: Parameters?) -> httpResult {
        return requestData(.delete, baseURL + api.path(),
                           parameters: param,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.header())
    }
    
    func formDataPost(_ api: PiPiAPI, param: Parameters, img: Data?) -> DataRequest {
        return AF.upload(multipartFormData: { (multipartFormData) in
            
            if img != nil {
                multipartFormData.append(img!, withName: "img", mimeType: "image/jpg")
            }
            
            for (key, value) in param { multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
            }
        }, to: baseURL + api.path(), method: .post, headers: api.header())
    }
}


enum networkingResult: Int {
    case ok1 = 201
    case ok = 200
    case wrongRq = 400
    case noToken = 401
    case endToken = 403
    case notFound = 404
    case fault = 0
    case conflict = 409
}
