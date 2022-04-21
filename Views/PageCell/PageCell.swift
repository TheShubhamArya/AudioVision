//
//  PageCell.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit
import AVFoundation

class PageCell: UICollectionViewCell {
    
    static let identifier = "pageCellIdentifier"
    var service = SpeechSynthesizer()
    
    private var cardViews : (frontView: UIView, backView: UIView)?
    var frontView = FrontView()
    private var backView = BackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.quaternaryLabel.cgColor
        frontViewLayout()
        cardViews = (frontView: frontView, backView: backView)
    }
    
    public func configure(_ speechService: SpeechSynthesizer,at indexPath: IndexPath,_ image: UIImage) {
        let item = indexPath.item
        
        frontView.textView.text = speechService.speechTexts[item]
        frontView.pageNumberLabel.text = String(item + 1)
        frontView.buttonStack.emojiImageView.image = speechService.emojis[item]
        frontView.buttonStack.imageButton.addTarget(self, action: #selector(flipCardAnimation), for: .touchUpInside)
        
        backView.buttonStack.imageButton.addTarget(self, action: #selector(flipCardAnimation), for: .touchUpInside)
        backView.buttonStack.emojiImageView.image = speechService.emojis[item]
        
        service = speechService
        service.startSpeakingCounter = [Int](repeating: 0, count: service.speechTexts.count)
        service.isSpeaking = [Bool](repeating: false, count: service.speechTexts.count)
        backView.visionImage.image = image
        let wordsCount = speechService.speechTexts[indexPath.item].components(separatedBy: " ").count
        backView.characterLabel.text = "\(speechService.speechTexts[indexPath.item].count) characters and \(wordsCount) words"
    }
    
    private func frontViewLayout(){
        contentView.addSubview(frontView)
        frontView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            frontView.topAnchor.constraint(equalTo: contentView.topAnchor),
            frontView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            frontView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            frontView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func backViewLayout() {
        contentView.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc func flipCardAnimation() {
        if backView.superview != nil {
            frontViewLayout()
            cardViews = (frontView: backView, backView: frontView)
        } else {
            backViewLayout()
            cardViews = (frontView: frontView, backView: backView)
        }
        
        let transitionOption = UIView.AnimationOptions.transitionFlipFromBottom
        UIView.transition(with: self.contentView, duration: 0.75, options: transitionOption) {
            // animations
            self.cardViews?.frontView.removeFromSuperview()
            self.contentView.addSubview(self.cardViews!.backView)
        } completion: { finished in
            // once animation is finished
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension PageCell : AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttributes([.backgroundColor: UIColor.systemYellow, .font: UIFont.systemFont(ofSize: 17, weight: .regular)], range: characterRange)
        frontView.textView.attributedText = mutableAttributedString
        frontView.textView.textColor = .label
        frontView.textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        frontView.textView.attributedText = NSAttributedString(string: utterance.speechString)
        frontView.textView.textColor = .label
        frontView.textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
}
