//
//  Token.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation

struct TokenModel: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}

struct Token {
    static var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "Token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Token")
        }
    }
}
