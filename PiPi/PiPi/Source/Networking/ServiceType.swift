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

class ServiceType {
    let baseURL = "http://18.223.24.131"
    
    typealias HTTPResult = Observable<(HTTPURLResponse, Data)>
    
    func requestDate(_ api: PiPiAPI) -> HTTPResult {
        return RxAlamofire.requestData(api.method(), baseURL + api.path(), parameters: api.param, encoding: JSONEncoding.prettyPrinted, headers: api.header())
    }
}


enum networkingResult: Int {
    case ok = 200
    case wrongRq = 400
    case noToken = 401
    case endToken = 403
    case notFound = 404
    case fault = 0
    case conflict = 409
}
