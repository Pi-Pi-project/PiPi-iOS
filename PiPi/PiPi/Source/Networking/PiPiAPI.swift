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
    case signIn(_ email: String, _ password: String)
    case refreshToken
    case postAuthCode(_ email: String)
    case checkAuthCode(_ email: String, _ code: String)
    case register(_ email: String, _ password: String, _ nickname: String)
    case setProfile
    case changePw(_ email: String, _ password: String)
    case changePwSendEmail(_ email: String)
    case showUserInfo
    
    //Post
    case wirtePost
    case getPost(_ page: Int)
    case getDetailPost(_ id: String)
    case getApplyPosts(_ id: String)
    case projectApply(_ id: String)
    case deProjectApply(_ id: String)
    case getApplyList(_ id: String)
    case rejectApply(_ userEmail: String, _ postId: String)
    case acceptApply(_ userEmail: String, _ postId: String)
    case getMyPost(_ page: String)
    case searchPost(_ page: String, _ category: String)
    
    //Profile
    case getProfile(_ email: String)
    case getPortfolios(_ email: String)
    case addPorfolios(title: String, _ introduce: String, _ giturl: String)
    case selectPortfolio(_ first: Int, _ second: Int)
    
    //Projects
    case createProject(_ postId: String)
    case getProject(_ page: String)
    case createTodo(_ todo: String, _ date: String, projectId: Int)
    case getTodo(_ id: Int, _ date: String)
    case successTodo(_ id: String)
    case finishProject(id: Int, _ giturl: String, _ introduce: String)
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
    
    func method() -> HTTPMethod {
        switch self {
        case .postAuthCode, .checkAuthCode, .register, .setProfile, .changePwSendEmail, .signIn, .addPorfolios, .wirtePost, .projectApply, .createProject, .createTodo:
            return .post
        case .changePw, .selectPortfolio, .rejectApply, .acceptApply, .successTodo, .finishProject:
            return .put
        case .showUserInfo, .refreshToken, .getProfile, .getPortfolios, .getPost, .getDetailPost, .getApplyList, .getApplyPosts, .getMyPost, .searchPost, .getProject, .getTodo:
            return .get
        default:
            return .delete
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
    
    var param: Parameters? {
        switch self {
        case .signIn(let email, let password):
            return ["email": email, "password": password]
        case .postAuthCode(let email):
            return ["email": email]
        case .checkAuthCode(let email, let code):
            return ["email": email, "code": code]
        case .register(let email, let password, let nickname):
            return ["email": email, "password": password, "nickname": nickname]
        case .changePw(let email, let password):
            return ["email": email, "password": password]
        case .projectApply(let id), .deProjectApply(let id):
            return ["id": id]
        case .rejectApply(let userEmail, let postId), .acceptApply(let userEmail, let postId):
            return ["userEmail": userEmail, "postId": postId]
        case .createProject(let postId):
            return ["postId": postId]
        case .createTodo(let todo, let date, let projectId):
            return ["todo": todo, "date": date, "projectId": projectId]
        case .finishProject(let id, let giturl, let introduce):
            return ["id": id, "giturl": giturl, "introduce": introduce]
        default:
            return nil
        }
    }
}



