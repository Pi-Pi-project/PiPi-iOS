//
//  PortfolioTableViewCell.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/19.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {

    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var giturlLabel: UILabel!
    @IBOutlet weak var moreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(_ model: portfolio) {
        projectNameLabel.text = model.title
        giturlLabel.text = model.giturl
        moreLabel.text = model.introduce
    }
}
