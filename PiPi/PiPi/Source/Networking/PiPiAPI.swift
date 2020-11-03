//
//  PiPi.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import Alamofire

enum PiPiAPI {
    
    //Auth
    case signIn
    case refreshToken
    case postAuthCode
    case checkAuthCode
    case register
    case setProfile
    case changePw
    
    //Post
    case wirtePost
    case getPost(_ page: Int)
    case getDetailPost(_ id: String)
    case projectApply
    case getApplyList(_ id: String)
    case rejectApply
    case acceptApply
    case getMyPost
    
    //Projects
    case createProject
    case projectList
    
    func path() -> String {
        switch self {
        case .signIn:
            return "/auth"
        case .refreshToken:
            return "/auth/refresh"
        case .postAuthCode:
            return "/user/email"
        case .checkAuthCode:
            return "/user/email/check"
        case .register:
            return "/user"
        case .setProfile:
            return "/user/profile"
        case .changePw:
            return "/user/password"
        case .wirtePost:
            return "/post"
        case .getPost(let page):
            return "/post?page=0"
        case .getDetailPost(let id):
            return "/post/\(id)"
        case .projectApply:
            return "/post/apply"
        case .getApplyList:
            return "/post/apply"
        case .rejectApply:
            return "/post/apply/reject"
        case .acceptApply:
            return "/post/apply/accept"
        case .getMyPost:
            return "/post/mine?page=0"
        case .createProject, .projectList:
            return "/project"
        }
    }
    
    func header() -> HTTPHeaders? {
        return ["Authorization" : "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDQzNzI5NzIsImV4cCI6MzAwMDAxNjA0MzcyOTcyLCJzdWIiOiJzZXVuZ2Jpbjk4NTBAZHNtbS5ocy5rciIsInR5cGUiOiJhY2Nlc3NUb2tlbiJ9.yllsKaZQKakD7XIqpvbD8Do04-I72FapK3i9sOiYgcc"]
    }
}
