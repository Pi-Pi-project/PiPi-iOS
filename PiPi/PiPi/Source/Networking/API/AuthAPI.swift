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
    
    let baseURL = "http://15.164.245.146"
    let httpClient = HTTPClient()
    
    func sendAuthCode(_ email: String) -> Observable<networkingResult> {
        httpClient.post(.postAuthCode, param: ["email": email])
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
          }
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
        httpClient.post(.checkAuthCode, param: ["email":email, "code":code])
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
          }
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
        httpClient.post(.register, param: ["email": email, "password": pw, "nickname": nickName]).map { response, data -> networkingResult in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func setProfile(_ api: PiPiAPI, param: Parameters, img: Data?) -> DataRequest {
        return AF.upload(multipartFormData: { (multipartFormData) in
            print(self.baseURL + api.path())
            if img != nil {
                multipartFormData.append(img!, withName: "profileImg", mimeType: "image/jpg")
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
    
    func changePassword(_ email: String, _ pw: String) -> Observable<networkingResult> {
        httpClient.put(.changePw,
                        param: ["email": email, "password": pw])
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
              }.map{ response, data -> networkingResult in
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
        httpClient.post(.signIn,
                        param: ["email": email, "password": pw])
            .map{ response, data -> networkingResult in
                print(response.statusCode)
                switch response.statusCode {
                case 200:
                    guard let data = try? JSONDecoder().decode(TokenModel.self, from: data) else { return .fault }
                    Token.token = data.accessToken
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
        httpClient.post(.changePwSendEmail, param: ["email":email]).catchError{ error -> Observable<(HTTPURLResponse, Data)> in
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
          }.map { resposne, data -> networkingResult in
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
