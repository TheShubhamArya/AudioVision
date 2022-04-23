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
    
    let controlView = ControlView()
    
    
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
//        let vc = WelcomeView()
//        let host = UIHostingController(rootView: vc)
//        present(host, animated: true, completion: nil)
    }
    
    func setupNavbar() {
        self.title = "AudioVision"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.badge.ellipsis"), style: .plain, target: self, action: #selector(mediaTypeAlert))
        let tutorialButton = UIBarButtonItem(title: "Tutorial", style: .plain, target: self, action: #selector(tutorialButtonTapped))
        let aboutButton = UIBarButtonItem(title: "About", style: .plain, target: self, action: #selector(aboutButtonTapped))
        navigationItem.rightBarButtonItems = [aboutButton, tutorialButton]
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
    
    @objc func mediaTypeAlert() {
        let actionSheet = UIAlertController(title: "Select Media Type", message: "", preferredStyle: .actionSheet)
        
        let liveDetection = UIAlertAction(title: "Live Detection", style: .default) { [weak self]_ in
            self?.openLiveCameraView()
        }
        
        let imageStitch = UIAlertAction(title: "Image Stitching Detection", style: .default) { [weak self] _ in
            self?.openImageStitcherView()
        }
        
        let camera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.speechService.speechTexts = []
            self?.openCamera()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if let popoverPresentationController = actionSheet.popoverPresentationController {
          popoverPresentationController.sourceView = self.view
          popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
          popoverPresentationController.permittedArrowDirections = []
        }
        actionSheet.addAction(liveDetection)
        actionSheet.addAction(imageStitch)
        actionSheet.addAction(camera)
        
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true)
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

extension HomeVC : SpeechRecognizerDelegate {
    
    func didSayCorrectKeyword(for keyword: KeyWords) {
        speechRecognizer.stopRecognizingSpeech()
        if keyword == .openCamera {
            openCamera()
            return
        } else if keyword == .readToMe {
            playButtonTapped()
        }
//        else if keyword == .pause {
//            playButtonTapped()
//        } else if keyword == .readNext {
//            forwardButtonTapped()
//        } else if keyword == .readPrevious{
//            backButtonTapped()
//        }
        else if keyword == .openLiveDetection {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if speechService.speechTexts.isEmpty {
            collectionView.setEmptyView(title: "How it works?", message: K.emptyCollectionViewText)
            return 0
        }
        collectionView.restore()
        return speechService.speechTexts.count
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
        guard let pageCell = collectionView.dequeueReusableCell(withReuseIdentifier: PageCell.identifier, for: indexPath) as? PageCell else {return UICollectionViewCell()}
        pageCell.backgroundColor = .clear
        pageCell.configure(speechService, at: indexPath, visionImages[item])
        return pageCell
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
            
            let groupHeight = NSCollectionLayoutDimension.absolute(300)
            var groupWidth = NSCollectionLayoutDimension.fractionalWidth(1)
            
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
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 8, bottom: 5, trailing: 8)
            return section
        }
        return layout
    }
}
