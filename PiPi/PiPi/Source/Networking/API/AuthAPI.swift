//
//  AuthAPI.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/21.
//

import Foundation
import RxSwift

private let httpClient = HTTPClient()

class AuthAPI: AuthProvider {
    
    func sendAuthCode(_ email: String) -> Observable<networkingResult> {
        httpClient.post(.postAuthCode, param: ["email": email])
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
            switch response.statusCode {
            case 201:
                return .ok1
            default:
                return .fault
            }
        }
    }
    
    //수정
    func setProfile(_ email: String, skils: [String?], gitURL: String, userImg: String) -> Observable<networkingResult> {
        httpClient.post(.setProfile,
                        param: ["email": email, "password": gitURL])
            .map{ response, data -> networkingResult in
                switch response.statusCode {
                case 200:
//                    guard let data = try? JSONDecoder().decode(Token.self, from: data) else { return .fault }
//                    print(data)
                    return .ok
                case 404:
                    return .notFound
                default:
                    print(response.statusCode)
                    return .fault
                }
            }
    }
    
    func changePassword(_ email: String, _ pw: String) -> Observable<networkingResult> {
        httpClient.post(.changePw,
                        param: ["email": email, "password": pw])
            .map{ response, data -> networkingResult in
                switch response.statusCode {
                case 200:
//                    guard let data = try? JSONDecoder().decode(Token.self, from: data) else { return .fault }
//                    print(data)
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
//                    guard let data = try? JSONDecoder().decode(Token.self, from: data) else { return .fault }
//                    print(data)
                    return .ok
                case 404:
                    return .notFound
                default:
                    print(response.statusCode)
                    return .fault
                }
            }
    }
    
}
