//
//  Provider.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/21.
//

import Foundation
import RxSwift

protocol AuthProvider {
//    func sendAuthCode(_ email: String) -> Observable<networkingResult>
//    func checkAuthCode(_ email: String,_ code: String) -> Observable<networkingResult>
//    func register(_ email: String, _ pw: String, _ nickName: StaticString) -> Observable<networkingResult>
//    func setProfile(_ email: String, skils: [String?], gitURL: String, userImg: String) -> Observable<networkingResult>
//    func changePassword(_ email: String, _ pw: String) -> Observable<networkingResult>
    func signIn(_ email: String, _ pw: String) -> Observable<networkingResult>
//    func refreshToken(_ token: String) -> Observable<networkingResult>
}
