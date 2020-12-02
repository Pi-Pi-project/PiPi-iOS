//
//  Provider.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/21.
//

import Foundation
import RxSwift

protocol AuthProvider {
    func sendAuthCode(_ email: String) -> Observable<networkingResult>
    func checkAuthCode(_ email: String,_ code: String) -> Observable<networkingResult>
    func register(_ email: String, _ pw: String, _ nickName: String) -> Observable<networkingResult>
    func setProfile(_ email: String, skils: [String?], gitURL: String, userImg: String) -> Observable<networkingResult>
    func changePassword(_ email: String, _ pw: String) -> Observable<networkingResult>
    func signIn(_ email: String, _ pw: String) -> Observable<networkingResult>
//    func refreshToken(_ token: String) -> Observable<networkingResult>
}


protocol PostProvider {
//    func wirtePost(_ title: String, _ category: String, _ skills: [String], _ max: Int) -> Observable<networkingResult>
//    func getPosts() -> Observable<networkingResult>
//    func getDetailPost() -> Observable<networkingResult>
//    func postProjectApply(_ id: String) -> Observable<networkingResult>
//    func getApplyList(_ id: String) -> Observable<networkingResult>
//    func deleteRejectApply(_ userEmail: String, _ postID: String) -> Observable<networkingResult>
//    func postAcceptApply(_ userEmail: String, _ postID: String) -> Observable<networkingResult>
}
