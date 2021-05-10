//
//  NVActivityIndicatorAnimationCubeTransition.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 12/12/2020.
//

#if canImport(UIKit)
import UIKit

class NVActivityIndicatorAnimationCubeTransition: NVActivityIndicatorAnimationDelegate {

    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let squareSize = size.width / 5
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let deltaX = size.width - squareSize
        let deltaY = size.height - squareSize
        let duration: CFTimeInterval = 1.6
        let beginTime = CACurrentMediaTime()
//        let beginTimes: [CFTimeInterval] = [0, -0.8] // original beginTimes
        let beginTimes: [CFTimeInterval] = [0, -1, -2.5, -2.8]
        let timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")

        let translateAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        let animation = CAAnimationGroup()

        animation.animations = [scaleAnimation, translateAnimation, rotateAnimation]
        animation.duration = duration
        scaleAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction, timingFunction, timingFunction]
        translateAnimation.keyTimes = scaleAnimation.keyTimes
        rotateAnimation.keyTimes = scaleAnimation.keyTimes
        rotateAnimation.timingFunctions = scaleAnimation.timingFunctions
        translateAnimation.timingFunctions = scaleAnimation.timingFunctions
        translateAnimation.duration = duration
        animation.repeatCount = HUGE
        translateAnimation.values = [
            NSValue(cgSize: CGSize(width: 0, height: 0)),
            NSValue(cgSize: CGSize(width: deltaX, height: 0)),
            NSValue(cgSize: CGSize(width: deltaX, height: deltaY)),
            NSValue(cgSize: CGSize(width: 0, height: deltaY)),
            NSValue(cgSize: CGSize(width: 0, height: 0))
        ]
        scaleAnimation.values = [1, 0.5, 1, 0.5, 1]
        scaleAnimation.duration = duration
        rotateAnimation.values = [0, -Double.pi / 2, -Double.pi, -1.5 * Double.pi, -2 * Double.pi]
        rotateAnimation.duration = duration
        animation.isRemovedOnCompletion = false
        
        // original
        // Draw squares
//        for i in 0 ..< 4 {
//            let square = NVActivityIndicatorShape.rectangle.layerWith(size: CGSize(width: squareSize, height: squareSize), color: color2)
//            let frame = CGRect(x: x, y: y, width: squareSize, height: squareSize)
//            animation.beginTime = beginTime + beginTimes[i]
//            square.frame = frame
//            square.add(animation, forKey: "animation")
//            layer.addSublayer(square)
//        }

        // Draw squares
        for i in 0 ..< 4 {
            if i == 3 {
                let color1 = UIColor.orange
                
                let square = NVActivityIndicatorShape.rectangle.layerWith(size: CGSize(width: squareSize, height: squareSize), color: color1)
                let frame = CGRect(x: x, y: y, width: squareSize, height: squareSize)
                animation.beginTime = beginTime + beginTimes[i]
                square.frame = frame
                square.add(animation, forKey: "animation")
                layer.addSublayer(square)
            }  else {
                let color2 = UIColor.link
                
                let square = NVActivityIndicatorShape.rectangle.layerWith(size: CGSize(width: squareSize, height: squareSize), color: color2)
                let frame = CGRect(x: x, y: y, width: squareSize, height: squareSize)
                animation.beginTime = beginTime + beginTimes[i]
                square.frame = frame
                square.add(animation, forKey: "animation")
                layer.addSublayer(square)
            }
        }
    }
}
#endif
