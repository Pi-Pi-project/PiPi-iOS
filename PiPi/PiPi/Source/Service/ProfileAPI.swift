//
//  ProfileAPI.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/13.
//

import Foundation
import RxSwift

class ProfileAPI {
    let httpClient = HTTPClient()
    
    func getProfile(_ email: String) -> Observable<(profileModel?, networkingResult)> {
        httpClient.get(.getProfile(email), param: nil).map { response, data -> (profileModel?, networkingResult) in
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
        httpClient.get(.getPortfolios(email), param: nil).map { (response, data) -> ([portfolio]?, networkingResult) in
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
        httpClient.post(.addPorfolios, param: ["title": title, "introduce": introduce, "giturl": giturl]).catchError{ error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://10.156.145.141:8080")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map { (response, data) -> (networkingResult) in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }
    
    func selectPortfolio(_ firstId: String, _ secondId: String) -> Observable<networkingResult> {
        httpClient.put(.selectPortfolio, param: ["first": firstId, "second": secondId]).catchError{ error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://10.156.145.141:8080")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }
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
        httpClient.get(.showUserInfo, param: nil).map { response, data -> (User?, networkingResult) in
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
