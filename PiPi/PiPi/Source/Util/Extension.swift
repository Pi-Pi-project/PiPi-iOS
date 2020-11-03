//
//  Extension.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import UIKit

extension UIColor {
    func hexUIColor(hex: String) -> UIColor {
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: CGFloat(1.0)
        )
    }
}

extension UIButton {
    open override var isEnabled: Bool {
        didSet {
            if self.isEnabled == true {
                self.backgroundColor = UIColor.magenta
                self.tintColor = .white
                //테두리
            }else {
                self.backgroundColor = UIColor.white
                self.tintColor = .magenta
            }
        }
    }
}

extension UIViewController {
    func moveScene(_ identifier: String) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(viewController!, animated: true)
    }
    
    func setUpErrorMessage(_ sender: UILabel, title: String, superTextField: UITextField) {
            sender.translatesAutoresizingMaskIntoConstraints = false
            sender.text = title
            sender.textColor = .red
            sender.isHidden = false
            sender.font = UIFont.systemFont(ofSize: CGFloat(9))

            view.addSubview(sender)

            NSLayoutConstraint.activate([
                sender.topAnchor.constraint(equalTo: superTextField.bottomAnchor),
                sender.leadingAnchor.constraint(equalTo: superTextField.leadingAnchor)
            ])
    }
    
    func setUpErrorHidden(_ sender: UILabel) {
        sender.isHidden = true
    }
    
    func setButton(_ button: UIButton) {
        if button.isEnabled {
            button.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
            button.layer.cornerRadius = 20
            button.tintColor = .white
        } else {
            button.backgroundColor = .clear
            button.layer.cornerRadius = 20
            button.layer.borderColor = UIColor().hexUIColor(hex: "61BFAD").cgColor
            button.layer.borderWidth = 1
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let Ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(Ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func circleOfImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.layer.borderWidth/2
    }
}

struct PiPiFilter {
    static func isEmpty(_ text: String) -> Bool {
        if text.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    static func checkEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,50}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
