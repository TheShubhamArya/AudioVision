//
//  HomeCategoryTableCell.swift
//  
//
//  Created by Shubham Arya on 4/6/22.
//

import UIKit

struct HomeCategory {
    let image : UIImage
    let name : String
    let backgroundColor : UIColor
    let description : String
}

class HomeCategoryCell: UICollectionViewCell {
    
    static let idenitifier = "HomeCategoryTableCellIdentifier"
    
    let categories : [HomeCategory] = [
        HomeCategory(image: UIImage(systemName: "video.fill")!, name: "Live", backgroundColor: .systemPink, description: "Quick text detection from live video"),
        HomeCategory(image: UIImage(systemName: "pano.fill")!, name: "Panorama", backgroundColor: .systemPurple, description: "Images are stitched together to detect  text"),
        HomeCategory(image: UIImage(systemName: "camera.fill")!, name: "Image", backgroundColor: .systemIndigo, description: "Capture multiple images and detect all texts at once")
    ]
    
    private let categoryImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let categoryNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let descriptionLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing = 5
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondarySystemGroupedBackground
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        contentView.addSubview(categoryImageView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(categoryNameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        layoutElements()
    }
    
    public func configure(for indexPath: IndexPath) {
        let category = categories[indexPath.item]
        categoryImageView.image = category.image
        categoryNameLabel.text = category.name
        descriptionLabel.text  =  category.description
        categoryImageView.tintColor = category.backgroundColor
    }
    
    private func layoutElements() {
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints =  false
        NSLayoutConstraint.activate([
            categoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            categoryImageView.heightAnchor.constraint(equalToConstant: 50),
            categoryImageView.widthAnchor.constraint(equalToConstant: 50),
            
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: categoryImageView.trailingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
