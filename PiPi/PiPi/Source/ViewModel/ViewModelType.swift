//
//  ViewModelType.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation

protocol ViewModelType {
    associatedtype input
    associatedtype output
    
    func transform(_ input: input) -> output
}
