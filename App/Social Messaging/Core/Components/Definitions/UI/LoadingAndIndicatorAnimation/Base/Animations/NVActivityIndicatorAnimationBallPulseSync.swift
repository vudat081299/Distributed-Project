//
//  NVActivityIndicatorAnimationBallPulseSync.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 12/12/2020.
//

#if canImport(UIKit)
import UIKit

class NVActivityIndicatorAnimationBallPulseSync: NVActivityIndicatorAnimationDelegate {

    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 5
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        let circleSize = (size.width - circleSpacing * 2) / 3
        let timingFunciton = CAMediaTimingFunction(name: .easeInEaseOut)
//        let circleSpacing: CGFloat = 2 // original
//        let circleSize = (size.width - circleSpacing * 2) / 3
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - circleSize) / 2
        let deltaY = (size.height / 2 - circleSize / 2) / 2
        let duration: CFTimeInterval = 1.2
        animation.keyTimes = [0, 0.33, 0.66, 1]
        animation.timingFunctions = [timingFunciton, timingFunciton, timingFunciton]
        animation.values = [0, deltaY, -deltaY, 0]
//        let duration: CFTimeInterval = 0.6 // original
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.1, 0.2, 0.3, 0.4]
//        let beginTimes: [CFTimeInterval] = [0.07, 0.14, 0.21] // original

        // Animation
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        for i in 0 ..< 4 {
            if i == 2 {
                
                let circle = NVActivityIndicatorShape.rectangle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: .orange)
                    let frame = CGRect(x: x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                                       y: y,
                                       width: circleSize,
                                       height: circleSize)

                    animation.beginTime = beginTime + beginTimes[i]
                    circle.frame = frame
                    circle.add(animation, forKey: "animation")
                    layer.addSublayer(circle)
            } else {
                
                let circle = NVActivityIndicatorShape.rectangle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: .link)
                    let frame = CGRect(x: x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                                       y: y,
                                       width: circleSize,
                                       height: circleSize)

                    animation.beginTime = beginTime + beginTimes[i]
                    circle.frame = frame
                    circle.add(animation, forKey: "animation")
                    layer.addSublayer(circle)
            }
        }
    }
}
#endif
