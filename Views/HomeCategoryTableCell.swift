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
}

class HomeCategoryTableCell: UITableViewCell {
    
    static let idenitifier = "HomeCategoryTableCellIdentifier"
    
    let categories : [HomeCategory] = [
        HomeCategory(image: UIImage(systemName: "camera.fill")!, name: "Capture Images from Camera", backgroundColor: .systemYellow),
        HomeCategory(image: UIImage(systemName: "photo.fill")!, name: "Select Image from Photo Library", backgroundColor: .systemRed),
        HomeCategory(image: UIImage(systemName: "video.fill")!, name: "Live Text Detection Around You", backgroundColor: .systemGreen),
        HomeCategory(image: UIImage(systemName: "folder.fill")!, name: "Choose a PDF File to Read Aloud", backgroundColor: .systemBlue)
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
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(categoryImageView)
        contentView.addSubview(categoryNameLabel)
        layoutElements()
    }
    
    public func configure(for indexPath: IndexPath) {
        let category = categories[indexPath.section]
        categoryImageView.image = category.image
        categoryNameLabel.text = category.name
        categoryImageView.tintColor = category.backgroundColor
    }
    
    private func layoutElements() {
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryImageView.heightAnchor.constraint(equalToConstant: 80),
            categoryImageView.widthAnchor.constraint(equalToConstant: 80),
            
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryNameLabel.leadingAnchor.constraint(equalTo: categoryImageView.trailingAnchor, constant: 20),
            categoryNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
