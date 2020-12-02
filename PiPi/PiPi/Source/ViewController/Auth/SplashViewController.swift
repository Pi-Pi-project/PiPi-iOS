//
//  SplashViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/21.
//

import UIKit
import RxSwift
import NSObject_Rx

class SplashViewController: UIViewController {

    @IBOutlet weak var introImageView: UIImageView!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        signInBtn.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
        signInBtn.tintColor = .white
        signInBtn.layer.cornerRadius = 20
        signUpBtn.layer.cornerRadius = 20
        
        signUpBtn.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
        signUpBtn.layer.borderWidth = 1
        signUpBtn.backgroundColor = .clear
        signUpBtn.layer.borderColor = UIColor().hexUIColor(hex: "61BFAD").cgColor
        signUpBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        
        signInBtn.rx.tap.subscribe(onNext: {
            self.moveScene("signIn")
        }).disposed(by: rx.disposeBag)
        
        signUpBtn.rx.tap.subscribe(onNext: {
            self.moveScene("signUp")
        }).disposed(by: rx.disposeBag)
    }
}
