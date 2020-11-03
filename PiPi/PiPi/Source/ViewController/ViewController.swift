//
//  ViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/16.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ViewController: UIViewController {

    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var joinIconBtn: UIButton!
    @IBOutlet weak var applyListBtn: UIButton!
    @IBOutlet weak var applyListIconBtn: UIButton!
    @IBOutlet weak var myPostBtn: UIButton!
    @IBOutlet weak var myPostIconBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinBtn.rx.tap.subscribe(onNext: {
            self.moveScene("joinVC")
        }).disposed(by: rx.disposeBag)
        
        applyListBtn.rx.tap.subscribe(onNext: {
            self.moveScene("applyVC")
        }).disposed(by: rx.disposeBag)
        
        myPostBtn.rx.tap.subscribe(onNext: {
            self.moveScene("mypostVC")
        }).disposed(by: rx.disposeBag)
        // Do any additional setup after loading the view.
    }

}

