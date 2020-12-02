//
//  MainModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import Foundation

struct postSkillsets: Codable {
    let postId: Int
    let skill: String
}

struct postModel: Codable {
    let id: Int
    let title: String
    let img: String?
    let category: String
    let idea: String
    let postSkillsets: [postSkillsets]
    let max: Int?
    let userEmail: String
    let userImg: String?
    let userNickname: String
    let createdAt: String
}

struct mainModel: Codable {
    let posts: [postModel]
}

struct detailModel: Codable {
    let userEmail: String
    let userImg: String?
    let userNickname: String
    let title: String
    let img: String
    let category: String
    let idea: String
    let postSkillsets: [postSkillsets]
    let content: String
    let max: Int?
    var applied: Bool
}

struct User: Codable {
    let email: String
    let profileImg: String
}

struct ApplyList: Codable{
    let userEmail: String
    let userNickname: String
    let userImg: String
    let status: String
}

struct Applies: Codable {
    let applies: [ApplyList]
}

struct roomId: Codable {
    let roomId: Int
}
