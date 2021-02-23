//
//  ProfileAPI.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/13.
//

import Foundation
import RxSwift

class ProfileAPI {
    let request = ServiceType()
    
    func getProfile(_ email: String) -> Observable<(profileModel?, networkingResult)> {
        request.requestDate(.getProfile(email))
            .map { response, data -> (profileModel?, networkingResult) in
            switch response.statusCode {
            case 200:
                do {
                    let data = try JSONDecoder().decode(profileModel.self, from: data)
                    return (data, .ok)
                }catch {
                    print(error)
                    return (nil, .fault)
                }
            default:
                return (nil, .fault)
            }
        }
    }
    
    func getPortfolios(_ email: String) -> Observable<([portfolio]?, networkingResult)> {
        request.requestDate(.getPortfolios(email))
            .map { (response, data) -> ([portfolio]?, networkingResult) in
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode([portfolio].self, from: data) else { return (nil, .fault) }
                
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }
    
    func addPortfolios(_ title: String, _ introduce: String, _ giturl: String) -> Observable<(networkingResult)> {
        request.requestDate(.addPorfolios(title: title, introduce, giturl))
            .map { (response, data) -> (networkingResult) in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func selectPortfolio(_ firstId: Int, _ secondId: Int) -> Observable<networkingResult> {
        request.requestDate(.selectPortfolio(firstId, secondId))
          .map {(response, data) -> networkingResult in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func showUserInfo() -> Observable<(User?,networkingResult)> {
        request.requestDate(.showUserInfo)
            .map { response, data -> (User?, networkingResult) in
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode(User.self, from: data) else { return (nil, .fault)}
                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }
    
}
