//
//  SocketIOManager.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/30.
//

import Foundation
import SocketIO
import RxCocoa

class SocketIOManager: NSObject {
    static let shared = SocketIOManager()
    var manager = SocketManager(socketURL: URL(string: "http://3.35.216.218:3000")!, config: [.log(false), .compress])
    var socket: SocketIOClient!
    var yours = PublishRelay<Any>()
    
    override init() {
        super.init()
        socket = self.manager.defaultSocket
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func sendMessage(_ roomId: Int, message: String, nickname: String) {
        socket.emit("chat", ["roomId": roomId, "userEmail": nickname, "message": message])
    }
}

