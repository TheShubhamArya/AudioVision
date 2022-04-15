//
//  FrontView.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit

class FrontView : UIView {
    
    var textView : UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .secondarySystemGroupedBackground
        tv.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        tv.textColor = .label
        return tv
    }()
    
    let pageNumberLabel : UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 13, weight: .thin)
        return label
    }()
    
    let buttonStack = ButtonStack()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(textView)
        self.addSubview(pageNumberLabel)
        self.addSubview(buttonStack)
        self.backgroundColor = .secondarySystemGroupedBackground
        textView.translatesAutoresizingMaskIntoConstraints = false
        pageNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            
            buttonStack.heightAnchor.constraint(equalToConstant: 30),
            buttonStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            buttonStack.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2),
            
            pageNumberLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            pageNumberLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            pageNumberLabel.heightAnchor.constraint(equalToConstant: 15),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

