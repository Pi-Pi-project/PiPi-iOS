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
    @IBOutlet var btnView: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let join = UITapGestureRecognizer(target: self, action: #selector(joinTapGesture(recognizer:)))
        let apply = UITapGestureRecognizer(target: self, action: #selector(applyTapGesture(recognizer:)))
        let myPost = UITapGestureRecognizer(target: self, action: #selector(myPostTapGesture(recognizer:)))
        
        setupUI()
        
        btnView[0].addGestureRecognizer(join)
        btnView[1].addGestureRecognizer(apply)
        btnView[2].addGestureRecognizer(myPost)
        
        joinBtn.rx.tap.subscribe(onNext: {
            self.moveScene("joinVC")
        }).disposed(by: rx.disposeBag)
        
        applyListBtn.rx.tap.subscribe(onNext: {
            self.moveScene("applyVC")
        }).disposed(by: rx.disposeBag)
        
        myPostBtn.rx.tap.subscribe(onNext: {
            self.moveScene("mypostVC")
        }).disposed(by: rx.disposeBag)
        
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupUI(){
        view.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
        joinBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        applyListBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        myPostBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        btnView[0].layer.cornerRadius = 10
        btnView[1].layer.cornerRadius = 10
        btnView[2].layer.cornerRadius = 10
    }
    
    @objc func joinTapGesture(recognizer: UITapGestureRecognizer) {
        self.moveScene("joinVC")
    }
    
    @objc func applyTapGesture(recognizer: UITapGestureRecognizer) {
        self.moveScene("applyVC")
    }
    
    @objc func myPostTapGesture(recognizer: UITapGestureRecognizer) {
        self.moveScene("mypostVC")
    }
}

