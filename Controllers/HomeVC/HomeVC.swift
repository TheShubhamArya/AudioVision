//
//  File.swift
//  AudioVision
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit
import Vision
import SwiftUI

class HomeVC : UIViewController {
    
    var collectionView : UICollectionView!
    
    var visionImages = [UIImage]()
    var currentReadingCell = 0
    
    var frontView = FrontView()
    let controlView = ControlView()
    
    // All Services that are used in this app
    let languageProcessor = LanguageProcessor()
    let speechService = SpeechSynthesizer()
    let speechRecognizer = SpeechRecognizer()
    let textDetector = TextDetector()
    
    var didOpenCamera = true
    var didOpenLiveDetection = true
    
    let activityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .gray
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        speechRecognizer.speechRecognizerDelegate = self
        view.backgroundColor = .systemBackground
        setupCollectionView()
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50)
        ])
        UserDefaults.standard.set(true, forKey: "firstTime")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if speechRecognizer.node == nil {
            speechRecognizer.speechRecognitionAuthorization()
        } else {
            speechRecognizer.stopRecognizingSpeech()
            speechRecognizer.recognizeSpeech()
        }
        didOpenCamera = true
        didOpenLiveDetection = true
        let _ = Timer.scheduledTimer(timeInterval: 59, target: self, selector: #selector(restartSpeechRecognition), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        speechRecognizer.stopRecognizingSpeech()
    }
    
    @objc func restartSpeechRecognition() {
        speechRecognizer.stopRecognizingSpeech()
        speechRecognizer.recognizeSpeech()
    }
    
    func setupNavbar() {
        self.title = "AudioVision"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Tutorial", style: .plain, target: self, action: #selector(tutorialButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "About", style: .plain, target: self, action: #selector(aboutButtonTapped))
    }
    
    @objc func aboutButtonTapped() {
        let vc = WelcomeView(fromHomeVC: true)
        let host = UIHostingController(rootView: vc)
        navigationController?.pushViewController(host, animated: true)
    }
    
    @objc func tutorialButtonTapped() {
        let vc = TutorialView(fromHomeView: true)
        let host = UIHostingController(rootView: vc)
        navigationController?.pushViewController(host, animated: true)
    }
    
    func openImageStitcherView() {
        let vc = ImageStitcherVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openLiveCameraView() {
        if didOpenLiveDetection {
            didOpenLiveDetection = false
            speechRecognizer.stopRecognizingSpeech()
            let vc = LiveCameraVC()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

//MARK: - Speech Recognizer delegate
extension HomeVC : SpeechRecognizerDelegate {
    
    func didSayCorrectKeyword(for keyword: KeyWords) {
        speechRecognizer.stopRecognizingSpeech()
        if keyword == .openCamera {
            openCamera()
            return
        } else if keyword == .readToMe {
            playButtonTapped()
        } else if keyword == .openLiveDetection {
            openLiveCameraView()
            return
        } else if keyword == .openImageStitching {
            openImageStitcherView()
        }
        speechRecognizer.recognizeSpeech()
    }
    
}


//MARK: - Collection view delegate
extension HomeVC : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return speechService.speechTexts.isEmpty ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let item = indexPath.item
        if section == 0 {
            if item == 0 {
                openLiveCameraView()
            } else if item == 1 {
                openImageStitcherView()
            } else if item == 2 {
                openCamera()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            collectionView.setEmptyView(title: "Welcome to AudioVison! An auxiliary for sight.", message: K.emptyCollectionViewText)
            return 3
        } else {
            collectionView.restore()
            return speechService.speechTexts.count
        }
    }
    
    func setupCollectionView(){
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayoutDiffSection())
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: PageCell.identifier)
        collectionView.register(HomeCategoryCell.self, forCellWithReuseIdentifier: HomeCategoryCell.idenitifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        collectionView.addGestureRecognizer(gesture)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let collectionView = collectionView else {return}
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
            break
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
            break
        case .ended:
            collectionView.endInteractiveMovement()
            break
        default:
            collectionView.cancelInteractiveMovement()
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        let section = indexPath.section
        if section == 1 {
            guard let pageCell = collectionView.dequeueReusableCell(withReuseIdentifier: PageCell.identifier, for: indexPath) as? PageCell else {return UICollectionViewCell()}
            pageCell.backgroundColor = .clear
            pageCell.configure(speechService, at: indexPath, visionImages[item])
            return pageCell
        } else {
            guard let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCategoryCell.idenitifier, for: indexPath) as? HomeCategoryCell else {return UICollectionViewCell()}
            categoryCell.configure(for: indexPath)
            return categoryCell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let speechItem = speechService.speechTexts.remove(at: sourceIndexPath.row)
        let imageItem = visionImages.remove(at: sourceIndexPath.row)
        speechService.speechTexts.insert(speechItem, at: destinationIndexPath.row)
        visionImages.insert(imageItem, at: destinationIndexPath.row)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func createLayoutDiffSection() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            var columns = 1
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 7, bottom: 5, trailing: 7)
            
            let groupHeight = sectionIndex == 0 ? NSCollectionLayoutDimension.absolute(120) : NSCollectionLayoutDimension.absolute(300)
            let groupWidth = NSCollectionLayoutDimension.fractionalWidth(1)
            
            if self.collectionView.frame.size.width > 500 || self.collectionView.frame.size.height > 1000{
                columns = 2
            }
            
            let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth,
                                                   heightDimension: groupHeight)
            if sectionIndex == 0 {
                columns = 3
            }
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            
            let section = NSCollectionLayoutSection(group: group)
            if sectionIndex == 0 {
                let layoutSectionHeader = self.createSectionHeader(with: sectionIndex)
                section.boundarySupplementaryItems = [layoutSectionHeader]
            }
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 8, bottom: 5, trailing: 8)
            return section
        }
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        
        case UICollectionView.elementKindSectionHeader:
            if indexPath.section == 0 {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else {return UICollectionReusableView()}
                headerView.configure(with: "Text Detections")
                return headerView
            }
            
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    private func createSectionHeader(with section: Int) -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(25))

        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return layoutSectionHeader
    }
}
