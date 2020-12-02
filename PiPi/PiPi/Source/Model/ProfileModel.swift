//
//  ProfileModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/13.
//

import Foundation


struct profileModel: Codable {
    let profileImg: String
    let nickname: String
    let skills: [skill]
    let giturl: String?
    let introduce: String?
    let firstPortfolio: portfolio?
    let secondPortfolio: portfolio?
    let userEmail: String
}

struct skill: Codable {
    let userEmail: String
    let skill: String
}

struct portfolio: Codable {
    let id: Int
    let userEmail: String
    let title: String
    let giturl: String?
    let introduce: String?
}

