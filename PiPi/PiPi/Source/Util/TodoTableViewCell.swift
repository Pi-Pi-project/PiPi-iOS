//
//  TodoTableViewCell.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/20.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        lineView.backgroundColor = .gray
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
