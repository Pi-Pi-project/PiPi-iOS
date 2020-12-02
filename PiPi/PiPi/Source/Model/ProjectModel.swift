//
//  ProjectModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/19.
//

import Foundation
import SocketIO

struct ProjectModel: Codable {
    let id: Int
    let title: String
}

struct Projects: Codable {
    var Projects: [ProjectModel]
}

struct todo: Codable {
    let id: Int
    let nickname: String
    let date: String
    let todo: String
    let todoStatus: String
}

struct room: Codable {
    let id: Int
    let title: String
    let coverImg: String?
}

struct chat: SocketData {
    let roomid: Int
    let userEmail: String
    let message: String
}

struct getChat: Codable {
    let userNickname: String
    let message: String
    let mine: Bool
    let profileImg: String
}
