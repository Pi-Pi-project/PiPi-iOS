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
    func signIn(_ email: String, _ pw: String) -> Observable<networkingResult> {
        httpClient.post(.signIn,
                        param: ["email": email, "password": pw])
            .map{ response, data -> networkingResult in
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
}
