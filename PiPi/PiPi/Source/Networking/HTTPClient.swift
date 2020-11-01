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
    let baseURL = "http://10.156.145.141:8080"
    
    typealias httpResult = Observable<(HTTPURLResponse, Data)>
    
    func get(_ api: PiPiAPI, param: Parameters?) -> httpResult {
        return requestData(.get, baseURL + api.path(),
                           parameters: param,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.header())
    }
    
    func post(_ api: PiPiAPI, param: Parameters?) -> httpResult {
        return requestData(.post, baseURL + api.path(),
                           parameters: param,
                           encoding: JSONEncoding.prettyPrinted,
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
