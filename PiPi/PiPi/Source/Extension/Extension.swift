//
//  Extension.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
        
    func moveReference() {
        let mainView: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = mainView.instantiateViewController(identifier: "main")
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: false, completion: nil)
    }
    
    func moveScene(_ identifier: String) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(vc!, animated: true)
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
            button.layer.cornerRadius = 10
            button.tintColor = .white
        } else {
            button.backgroundColor = .clear
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor().hexUIColor(hex: "61BFAD").cgColor
            button.layer.borderWidth = 1
        }
    }
    
    func setButton(_ button: UIButton, _ isApply: Bool) {
        if isApply {
            button.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
            button.layer.cornerRadius = 10
            button.tintColor = .white
            button.setTitle("취소하기", for: .normal)
        } else {
            button.backgroundColor = .clear
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor().hexUIColor(hex: "61BFAD").cgColor
            button.layer.borderWidth = 1
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let Ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(Ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setListBtn(_ access: UIButton, _ reject: UIButton, _ status: String){
        if status == "WAITING"{
            reject.backgroundColor = .clear
            reject.layer.cornerRadius = 10
            reject.layer.borderColor = UIColor().hexUIColor(hex: "61BFAD").cgColor
            reject.layer.borderWidth = 1
            
            access.backgroundColor = .clear
            access.layer.cornerRadius = 10
            access.layer.borderColor = UIColor().hexUIColor(hex: "61BFAD").cgColor
            access.layer.borderWidth = 1
            access.tintColor = UIColor().hexUIColor(hex: "61BFAD")
        } else if status == "ACCEPTED" {
            reject.backgroundColor = .clear
            reject.layer.cornerRadius = 10
            reject.layer.borderColor = UIColor().hexUIColor(hex: "61BFAD").cgColor
            reject.layer.borderWidth = 1
            reject.tintColor = UIColor().hexUIColor(hex: "61BFAD")
            access.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
            access.layer.cornerRadius = 10
            access.tintColor = .white
        }else {
            access.backgroundColor = .clear
            access.layer.cornerRadius = 10
            access.layer.borderColor = UIColor().hexUIColor(hex: "61BFAD").cgColor
            access.layer.borderWidth = 1
            access.tintColor = UIColor().hexUIColor(hex: "61BFAD")
            
            reject.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
            reject.layer.cornerRadius = 10
            reject.tintColor = .white
            reject.layer.borderWidth = 1
        }
    }
    
    func circleOfImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.layer.borderWidth/2
    }
    
    func setBorder(_ textfield: UILabel) {
        textfield.layer.cornerRadius = 10
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.layer.borderWidth = 1
    }
}

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
    
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.setBackgroundImage(image, for: .normal)
                    }
                }
            }
        }
    }
}

struct PiPiFilter {
    static func checkEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,50}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

extension String {
    func stringUpper(_ text: String) -> String {
        let replace = text.replacingOccurrences(of: "(\\p{UppercaseLetter}\\p{LowercaseLetter}|\\p{UppercaseLetter}+(?=\\p{UppercaseLetter}))",
                                            with: " $1",
                                            options: .regularExpression,
                                            range: range(of: self)
        )
        .capitalized
        return replace.replacingOccurrences(of: " ", with: "")
    }
    
    func spaceArray() -> [String] {
        let arr = self.components(separatedBy: " ")
        return arr
    }
    
}

extension UIImage {
    func toString() -> String? {
        let data: Data? = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}

extension BehaviorRelay where Element: RangeReplaceableCollection {
    func add(element: Element.Element) {
        var array = self.value
        array.append(element)
        self.accept(array)
    }
    
    func insert(element: Element.Element) {
        var array = self.value
        array.insert(element, at: 0 as! Element.Index)
        self.accept(array)
    }
}
