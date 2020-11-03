//
//  MainModel.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import Foundation

//        "id": project id,
//        "title": "project title",
//        "img": "project cover img",
//        "category": "project category",
//        "idea": "project idea",
//        "postSkillsets": [
//            {
//                "postId": post id,
//                "skill": "project skills"
//            }
//        ],
//        "max": max member,
//        "userEmail": "post writer email",
//        "userImg": "post writer img",
//        "userNickname": "post writer nickname",
//        "createdAt": "post created at"

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
    let User: User?
    let title: String
    let img: String
    let category: String
    let idea: String
    let postSkillsets: [postSkillsets]
    let content: String
    let max: Int?
}

struct User: Codable {
    let nickname: String
    let img: String
}
