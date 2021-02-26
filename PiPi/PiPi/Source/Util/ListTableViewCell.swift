//
//  ListTableViewCell.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import UIKit
import RxSwift

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var accessBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        accessBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        rejectBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configCell(_ model: ApplyList) {
        let url = URL(string: "https://pipi-project.s3.ap-northeast-2.amazonaws.com/\(model.userImg)")
        userImageView.kf.setImage(with: url)
        userName.text = model.userNickname
    }
}
