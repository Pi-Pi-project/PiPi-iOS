//
//  MainTableViewCell.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/02.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var skilsLabel: UILabel!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var userImgBtn: UIButton!
    @IBOutlet weak var applyListBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    func setupUI() {
        coverView.backgroundColor = .black
        coverView.alpha = 0.5
        
        projectLabel.textColor = .white
        
        skilsLabel.clipsToBounds = true
        skilsLabel.backgroundColor = .white
        skilsLabel.textColor = .black
        skilsLabel.layer.cornerRadius = 4
        
        applyListBtn.backgroundColor = .white
        applyListBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        applyListBtn.layer.cornerRadius = 10
        
        applyListBtn.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}


func circleOfImageView(_ imageView: UIImageView) {
    imageView.layer.cornerRadius = imageView.layer.borderWidth/2
}
