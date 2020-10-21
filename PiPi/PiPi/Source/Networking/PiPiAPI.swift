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
    case sendAuthCode
    case checkAuthCode
    case register
    case setProfile
    case changePw
    
    //Post
    case wirtePost
    case getPost(_ page: Int)
    case getDetailPost(_ id: String)
    case projectApply
    case getApplyList
    case rejectApply
    case acceptApply
    
    //Projects
    case createProject
    case projectList
    
    func path() -> String {
        switch self {
        case .signIn:
            return "/auth"
        case .refreshToken:
            return "/auth/refresh"
        case .sendAuthCode:
            return "/email"
        case .checkAuthCode:
            return "/email/check"
        case .register:
            return "/user"
        case .setProfile:
            return "/user/profile"
        case .changePw:
            return "/user/password"
        case .wirtePost:
            return "/post"
        case .getPost(let page):
            return "/post/\(page)"
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
        case .createProject, .projectList:
            return "/project"
        }
    }
    
    func header() -> HTTPHeaders? {
        switch self {
        default:
            return nil
        }
    }
}
