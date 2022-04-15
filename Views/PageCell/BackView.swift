//
//  BackView.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit

class BackView : UIView {
    
    let visionImage : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let characterLabel : UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        return label
    }()
    
    let buttonStack = ButtonStack()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(visionImage)
        self.addSubview(buttonStack)
        self.addSubview(characterLabel)
        self.backgroundColor = .secondarySystemGroupedBackground
        visionImage.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            visionImage.topAnchor.constraint(equalTo: self.topAnchor),
            visionImage.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            visionImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            visionImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            buttonStack.heightAnchor.constraint(equalToConstant: 30),
            buttonStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            buttonStack.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2),
            
            characterLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            characterLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            characterLabel.trailingAnchor.constraint(equalTo: buttonStack.leadingAnchor, constant: -5),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

