//
//  HeaderView.swift
//  
//
//  Created by Shubham Arya on 4/23/22.
//

import UIKit

class HeaderView: UICollectionReusableView {
    static let identifier = "HeaderForCategoryWithText"
    let defaults = UserDefaults.standard

    private let headerLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(headerLabel)
        layoutElements()
    }
    
    func configure(with header: String){
        headerLabel.text = header
    }
    
    private func layoutElements() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
