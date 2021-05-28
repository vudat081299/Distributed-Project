//
//  UIView.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 18/12/2020.
//

import UIKit

extension UIView {
    func roundedBorder() {
        clipsToBounds = true
        layer.cornerRadius = self.frame.size.height / 2
    }
    func border(_ radius: CGFloat = 10) {
        clipsToBounds = true
        layer.cornerRadius = radius
    }
    func minEdgeBorder() {
        clipsToBounds = true
        layer.cornerRadius = frame.size.height > frame.size.width ? frame.size.width / 2 : frame.size.height / 2
    }
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowRadius = 3.0
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func borderOutline(_ width: CGFloat = 1, color: UIColor = .black) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}

public let kShapeDashed : String = "kShapeDashed"
extension UIView {
    
    func removeDashedBorder(_ view: UIView) {
        view.layer.sublayers?.forEach {
            if kShapeDashed == $0.name {
                $0.removeFromSuperlayer()
            }
        }
    }

    func addDashedBorder(width: CGFloat? = nil, height: CGFloat? = nil, lineWidth: CGFloat = 2, lineDashPattern:[NSNumber]? = [6,3], strokeColor: UIColor = UIColor.red, fillColor: UIColor = UIColor.clear) {
        
        
        var fWidth: CGFloat? = width
        var fHeight: CGFloat? = height
        
        if fWidth == nil {
            fWidth = self.frame.width
        }
        
        if fHeight == nil {
            fHeight = self.frame.height
        }
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()

        let shapeRect = CGRect(x: 0, y: 0, width: fWidth!, height: fHeight!)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: fWidth!/2, y: fHeight!/2)
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = lineDashPattern
        shapeLayer.name = kShapeDashed
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 8).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
}
