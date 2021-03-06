//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit

extension UICollectionView {
    
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x,
                                             y: self.center.y,
                                             width: self.bounds.size.width,
                                             height: self.bounds.size.height))
        
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 20
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .systemFont(ofSize: 17, weight: .medium)
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        emptyView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20),
        ])
        self.backgroundView = emptyView
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
}
