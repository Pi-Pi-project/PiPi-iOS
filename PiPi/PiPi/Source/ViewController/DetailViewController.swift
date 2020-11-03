//
//  DetailViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class DetailViewController: UIViewController {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var ppNameLabel: UILabel!
    @IBOutlet weak var ppSkillLabel: UILabel!
    @IBOutlet weak var ppIntroLabel: UILabel!
    @IBOutlet weak var ppDetailTextView: UITextView!
    @IBOutlet weak var ppMaxLabel: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    
    private let viewModel = DetailViewModel()
    private let loadDetail = BehaviorRelay<Void>(value: ())
    
    var selectIndexPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        let input = DetailViewModel.input(loadDetail: loadDetail.asSignal(onErrorJustReturn: ()), selectIndexPath: selectIndexPath)
        let output = viewModel.transform(input)
        
        DetailViewModel.loadDetail.asObservable().subscribe(onNext: { result in
            let backimg = URL(string: "http://10.156.145.141:8080/image/\(result.img)/")
            self.backImageView.kf.setImage(with: backimg)
            let userimg = URL(string: "http://10.156.145.141:8080/image/\(result.User?.img ?? "")/")
            self.userImg.kf.setImage(with: userimg)
            self.circleOfImageView(self.userImg)
            self.userImg.image = UIImage(named: result.User?.img ?? "")
            self.userName.text = result.User?.nickname
            self.ppNameLabel.text = result.title
            self.ppSkillLabel.text = " df"
            self.ppDetailTextView.text = result.content
            self.ppMaxLabel.text = String(format: "0", result.max ?? "0")
        }).disposed(by: rx.disposeBag)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
