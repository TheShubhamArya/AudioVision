//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit

protocol DisplayImageProtocol {
    func displayImageExited(afterEditing editedImages: [UIImage])
}

class DisplayImageVC: UIViewController {
    
    var collectionView : UICollectionView!
    var capturedImages : [UIImage]!
    var delegate : DisplayImageProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        self.title = "\(capturedImages.count) images"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate.displayImageExited(afterEditing: capturedImages)
    }
    
    @objc func doneTapped() {
        delegate.displayImageExited(afterEditing: capturedImages)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func removeButtonTapped(_ sender: UIButton) {
        capturedImages.remove(at: sender.tag)
        self.title = "\(capturedImages.count) images"
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

}

extension DisplayImageVC : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {return UICollectionViewCell()}
        cell.configure(with: capturedImages[indexPath.item])
        cell.removeButton.tag = indexPath.item
        cell.removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    
    func setupCollectionView(){
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayoutDiffSection())
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func createLayoutDiffSection() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            var columns = 1
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)
            
            let groupHeight = NSCollectionLayoutDimension.fractionalHeight(0.7)
            var groupWidth = NSCollectionLayoutDimension.fractionalWidth(0.9)
            
            if self.collectionView.frame.size.width > 500 || self.collectionView.frame.size.height > 1000{
                columns = 2
                if sectionIndex == 4 {
                    groupWidth = NSCollectionLayoutDimension.absolute(600)
                }
            }
            
            let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth,
                                                   heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 8, bottom: 5, trailing: 8)
            return section
        }
        return layout
    }
    
}
