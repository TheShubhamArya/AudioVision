//
//  CircularProgressView.swift
//  
//
//  Created by Shubham Arya on 4/18/22.
//

import UIKit

class CircularProgressBarView: UIView {
    
    private var circleLayer = CAShapeLayer()
    var progressLayer = CAShapeLayer()
    private var startPoint = CGFloat(-Double.pi / 2)
    private var endPoint = CGFloat(3 * Double.pi / 2)


    override init(frame: CGRect) {
        super.init(frame: frame)
//        createCircularPath()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func createCircularPath(with point: CGPoint) {
        // created circularPath for circleLayer and progressLayer
        print("frame size is ",frame.size)
        let circularPath = UIBezierPath(arcCenter: point, radius: 45, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        // circleLayer path defined to circularPath
        circleLayer.path = circularPath.cgPath
        // ui edits
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 10.0
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor.white.cgColor
        // added circleLayer to layer
        layer.addSublayer(circleLayer)
        // progressLayer path defined to circularPath
        progressLayer.path = circularPath.cgPath
        // ui edits
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 5.0
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.green.cgColor
        // added progressLayer to layer
        layer.addSublayer(progressLayer)
    }
    
//    func progressAnimation(duration: TimeInterval) {
//        // created circularProgressAnimation with keyPath
//        CATransaction.begin()
//        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        // set the end time
//        circularProgressAnimation.duration = duration
//        circularProgressAnimation.toValue = 1.0
//        circularProgressAnimation.fillMode = .forwards
//        circularProgressAnimation.isRemovedOnCompletion = false
//        CATransaction.setCompletionBlock { [weak self] in
//            print("Animation is done do something again")
//        }
//        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
//        CATransaction.commit()
//    }

}
