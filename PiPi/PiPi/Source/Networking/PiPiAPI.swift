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
    case changePwSendEmail
    case showUserInfo
    
    //Post
    case wirtePost
    case getPost(_ id: Int)
    case getDetailPost(_ id: String)
    case getApplyPosts(_ id: String)
    case projectApply
    case deProjectApply
    case getApplyList(_ id: String)
    case rejectApply
    case acceptApply
    case getMyPost(_ page: String)
    case searchPost(_ category: String, _ page: Int)
    
    //Profile
    case getProfile(_ email: String)
    case getPortfolios(_ email: String)
    case addPorfolios
    case selectPortfolio
    
    //Projects
    case createProject
    case getProject(_ page: String)
    case createTodo
    case getTodo(_ id: Int, _ date: String)
    case successTodo(_ id: String)
    case finishProject
    case getRoom
    case getChats(_ id: Int, _ page: Int)
    case getIndividualCaht(_ email: String)
    
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
            return "/post?page=\(page)"
        case .getApplyPosts(let page):
            return "/post/apply?page=\(page)"
        case .getDetailPost(let id):
            return "/post/\(id)"
        case .projectApply, .deProjectApply:
            return "/post/apply"
        case .getApplyList(let id):
            return "/post/apply/\(id)"
        case .rejectApply:
            return "/post/apply/deny"
        case .acceptApply:
            return "/post/apply/accept"
        case .getMyPost(let page):
            return "/post/mine?page=\(page)"
        case .createProject:
            return "/project"
        case .changePwSendEmail:
            return "/user/password/email"
        case .searchPost(let category, let page):
            return "/post/search?category=\(category)&page=\(page)"
        case .getProfile(let email):
            return "/profile?email=\(email)"
        case .getPortfolios(let email):
            return "/profile/portfolio?email=\(email)"
        case .addPorfolios, .selectPortfolio:
            return "/profile/portfolio"
        case .getProject(let page):
            return "/project?page=\(page)"
        case .createTodo:
            return "/project/todo"
        case .getTodo(let id, let date):
            return "/project/todo?id=\(id)&date=\(date)"
        case .successTodo(let id):
            return "/project/todo/\(id)"
        case .finishProject:
            return "/project/complete"
        case .showUserInfo:
            return  "/user/info"
        case .getRoom:
            return "/room"
        case .getChats(let id, let page):
            return "/chat/\(id)?page=\(page)"
        case .getIndividualCaht(let email):
            return "/chat?email=\(email)"
        }
    }
    
    func header() -> HTTPHeaders? {
        switch self {
        case .signIn, .postAuthCode, .checkAuthCode, .register, .changePw:
            return nil
            
        case .refreshToken:
            let renewalToken: String = "tokenValue"
            let userDefault = UserDefaults.standard
            userDefault.set(renewalToken, forKey: "refreshToken")
            userDefault.synchronize(  )
            guard let token = userDefault.string(forKey: "refreshToken") else { return nil }
            return ["Authorization" : "Bearer " + token]
            
        default:
            guard let token = Token.token else { return [:] }
            return ["Authorization" : "Bearer " + token]
        }
    }
    
//    var param: Parameters? {
//        switch self {
//        case .signIn(let email, let password):
//            return ["email": email, "password": password]
//        case .refreshToken:
//            return
//        case .postAuthCode(let email):
//            return ["email": email]
//        case .checkAuthCode(let email, let code):
//            return ["email": email, "code": code]
//        case .register(let email, let password, let nickname):
//            return ["email": email, "password": password, "nickname": nickname]
//        case .setProfile(let email, let skills, let giturl, let profileImg):
//            return ["email": email, "skills": skills,]
//        case .changePw:
//            return
//        case .wirtePost:
//            return
//        case .getPost(let page):
//            return
//        case .getApplyPosts:
//            return
//        case .getDetailPost(let id):
//            return
//        case .projectApply, .deProjectApply:
//            return
//        case .getApplyList(let id):
//            return
//        case .rejectApply:
//            return
//        case .acceptApply:
//            return
//        case .getMyPost:
//            return
//        case .createProject, .projectList:
//            return
//        }
//    }
}



//case signIn(_ email: String, _ password: String)
//case refreshToken
//case postAuthCode(_ email: String)
//case checkAuthCode(_ email: String, _ code: String)
//case register(_ email: String, _ password: String, _ nickname: String)
//case setProfile(_ email: String, skills: [String],_ giturl: String, _ profileImg: String)
//case changePw(_ email: String, _ password: String)
//case changePwSendEmail(_ email: String)
//
////Post
//case wirtePost(_ title: String, _ category: String, _ skills: [String], _ idea: String, _ content: String, _ max: Int)
//case getPost(_ page: Int)
//case getDetailPost(_ id: String)
//
//case getApplyPosts(_ id: String)
//case projectApply(_ id: String)
//case deProjectApply(_ id: String)
//
//case getApplyList(_ id: String)
//case rejectApply(_ userEmail: String, _ postId: String)
//case acceptApply(_ userEmail: String, _ postId: String)
//
//case getMyPost(_ page: String)
//case searchPost(_ page: String, _ category: String)
