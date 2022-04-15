//
//  ControlView.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit

class ControlView : UIView  {
    
    let backgroundView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.opacity = 0.95
        view.layer.cornerRadius = 10
        return view
    }()
    
    public let backButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    public let playButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    public let forwardButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    public let pageLabel : UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 13, weight: .thin)
        return label
    }()
    
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 20
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backgroundView)
        self.addSubview(stackView)
        self.addSubview(pageLabel)
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(forwardButton)
        
        backgroundView.addSubview(stackView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10),
            
            pageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            pageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),        ])
    }
    
    public func changedButtonImage(_ isSpeaking: Bool) {
        if isSpeaking {
            playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
