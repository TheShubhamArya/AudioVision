//
//  InstructionView.swift
//  
//
//  Created by Shubham Arya on 4/20/22.
//

import UIKit

class InstructionView: UIView {
    
    let titleLable : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    let subtitleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 20
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(stackView)
        stackView.addArrangedSubview(titleLable)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    public func configure(with title: String,and subtitle: String,image imageName: String) {
        titleLable.text = title
        subtitleLabel.text = subtitle
        let rotateLeftImage = NSTextAttachment()

        rotateLeftImage.image = UIImage(systemName: imageName)?.withTintColor(.white)

        let fullString = NSMutableAttributedString(string:  subtitle)
        fullString.append(NSAttributedString(attachment: rotateLeftImage))
        fullString.append(NSAttributedString(string: " for max effectiveness."))
        
        subtitleLabel.attributedText = fullString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
