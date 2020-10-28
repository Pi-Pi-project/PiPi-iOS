//
//  Token.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation

class Token: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}
