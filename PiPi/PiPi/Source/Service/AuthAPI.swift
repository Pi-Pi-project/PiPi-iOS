//
//  AuthAPI.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/21.
//

import Foundation
import RxSwift
import Alamofire

class AuthAPI {
    
    let baseURL = "http://18.223.24.131"
    let request = ServiceType()
    
    func sendAuthCode(_ email: String) -> Observable<networkingResult> {
        request.requestDate(.postAuthCode(email))
          .map { response, data -> networkingResult in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
              print("send email")
              return .ok
            case 409:
              print("Dd")
              return .conflict
            default:
              print(response.statusCode)
              return .fault
            }
          }
      }
    
    func checkAuthCode(_ email: String, _ code: String) -> Observable<networkingResult> {
        request.requestDate(.checkAuthCode(email, code))
            .map { response, data -> networkingResult in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                return .ok
            case 401:
                return .noToken
            default:
                return .fault
            }
        }
    }
    
    func register(_ email: String, _ pw: String, _ nickName: String) -> Observable<networkingResult> {
        request.requestDate(.register(email, pw, nickName))
            .map { response, data -> networkingResult in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode(TokenModel.self, from: data) else { return .fault }
                Token.token = data.accessToken
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func setProfile(_ api: PiPiAPI, param: Parameters, img: Data?) -> DataRequest {
        return AF.upload(multipartFormData: { (multipartFormData) in
            if img != nil {
                multipartFormData.append(img!, withName: "profileImg",fileName: "image.jpg", mimeType: "image/jpg")
            }
            
            for (key, value) in param {
                if key == "skills" {
                    let arrayObj = value as! Array<Any>
                    for i in 0..<arrayObj.count {
                        let value = arrayObj[i] as! String
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                }else {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
                }
            }
        }, to: baseURL + api.path(), method: .post, headers: api.header())
    }
    
    func changePassword(_ email: String, _ pw: String) -> Observable<networkingResult> {
        request.requestDate(.changePw(email, pw))
            .map{ response, data -> networkingResult in
                print("pw \(response.statusCode)")
                switch response.statusCode {
                case 200:
                    return .ok
                case 404:
                    return .notFound
                default:
                    print(response.statusCode)
                    return .fault
                }
            }
    }
    
    func signIn(_ email: String, _ pw: String) -> Observable<networkingResult> {
        request.requestDate(.signIn(email, pw))
            .map{ response, data -> networkingResult in
                print(response.statusCode)
                switch response.statusCode {
                case 200:
                    guard let data = try? JSONDecoder().decode(TokenModel.self, from: data) else { return .fault }
                    Token.token = data.accessToken
                    print(data.accessToken)
                    return .ok
                case 404:
                    return .notFound
                default:
                    print(response.statusCode)
                    return .fault
                }
            }
    }
    
    func changPwSendEmail(_ email: String) -> Observable<networkingResult> {
        request.requestDate(.changePwSendEmail(email)).map { resposne, data -> networkingResult in
            switch resposne.statusCode {
            case 200:
                return .ok
            case 409:
                return .notFound
            default:
                return .fault
            }
        }
    }
}
