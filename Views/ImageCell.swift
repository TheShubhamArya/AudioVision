//
//  ImageCell.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    static let identifier = "ImageCellIdentifier"
    
    let capturedImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    let removeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private let backView : UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backView)
        backView.addSubview(capturedImageView)
        backView.addSubview(removeButton)
        backView.translatesAutoresizingMaskIntoConstraints = false
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: self.topAnchor),
            backView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            capturedImageView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 20),
            capturedImageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            capturedImageView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
            capturedImageView.bottomAnchor.constraint(equalTo: backView.bottomAnchor),
            
            removeButton.topAnchor.constraint(equalTo: backView.topAnchor),
            removeButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            removeButton.heightAnchor.constraint(equalToConstant: 25),
            removeButton.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    public func configure(with image: UIImage) {
        capturedImageView.image = image
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
