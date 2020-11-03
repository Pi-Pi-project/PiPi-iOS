//
//  ProjectAPI.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import Foundation
import RxSwift

class PostAPI{
    func wirtePost(_ title: String, _ category: String, _ skills: [String], _ idea: String, _ content: String,_ max: Int) -> Observable<networkingResult> {
        httpClient.post(.wirtePost, param: ["title": title, "category": category, "skills": skills, "idea": idea, "content": content, "max": max]).map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func getPosts() -> Observable<networkingResult> {
        httpClient.get(.getPost(7), param: nil).map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
//                guard let data = JSONDecoder().decode(Token.self, from: data)
                return .ok
            default:
                return .fault
            }
        }
    }

    func getDetailPost(_ id: String) -> Observable<networkingResult> {
        httpClient.get(.getDetailPost(id), param: nil).map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }

    func postProjectApply(_ id: String) -> Observable<networkingResult> {
        httpClient.post(.projectApply, param: ["id": id]).map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            case 404:
                return .notFound
            default:
                return .fault
            }
        }
    }

    func getApplyList(_ id: String) -> Observable<networkingResult> {
        httpClient.get(.getApplyList(id), param: nil).map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }

    func deleteRejectApply(_ userEmail: String, _ postID: String) -> Observable<networkingResult> {
        httpClient.delete(.rejectApply, param: ["userEmail": userEmail, "postId": postID]).map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }

    func postAcceptApply(_ userEmail: String, _ postID: String) -> Observable<networkingResult> {
        httpClient.post(.acceptApply, param: ["userEmail": userEmail, "postId":postID]).map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func getMyPost() -> Observable<networkingResult> {
        httpClient.post(.getMyPost, param: nil).map { response, data -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    

    
}