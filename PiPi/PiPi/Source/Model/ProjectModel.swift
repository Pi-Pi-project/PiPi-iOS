//
//  ProjectModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/19.
//

import Foundation

struct ProjectModel: Codable {
    let id: Int
    let title: String
}

struct Projects: Codable {
    var Projects: [ProjectModel]
}

struct todo: Codable {
    let id: String
    let nickname: String
    let date: String
    let todo: String
    let todoStatus: String
}
