//
//  FloatingBtn.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/13.
//

import Foundation
import UIKit

class FloatingBtn: UIButton {
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupButton()
        }
        
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupButton()
        }
        
        
        func setupButton() {
            setTitleColor(.white, for: .normal)
            backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
            titleLabel?.font     = UIFont(name: "AvenirNext-DemiBold", size: 18)
            layer.cornerRadius   = 40
            layer.borderWidth    = 3.0
            layer.masksToBounds = true
            
            NSLayoutConstraint.activate([
                trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
                heightAnchor.constraint(equalToConstant: 80),
                widthAnchor.constraint(equalToConstant: 80)
            ])

        }
    
}
