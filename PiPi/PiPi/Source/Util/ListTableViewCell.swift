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
    
    var cellDelegate: ListTableViewCellDelegate?
    var index = 0
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessBtn.rx.tap.subscribe(onNext: { _ in
            self.cellDelegate?.selectedInfoBtn(index: self.index)
            self.cellDelegate?.acceptChanged(self, isAccpet: self.accessBtn.isSelected)
        }).disposed(by: self.disposeBag)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

protocol ListTableViewCellDelegate {
    func acceptChanged(_ cell: ListTableViewCell, isAccpet: Bool)
    func selectedInfoBtn(index: Int)
}
