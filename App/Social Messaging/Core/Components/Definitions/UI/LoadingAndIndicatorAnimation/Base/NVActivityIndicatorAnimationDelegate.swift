//
//  NVActivityIndicatorAnimationDelegate.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 12/12/2020.
//

#if canImport(UIKit)
import UIKit

// swiftlint:disable:next class_delegate_protocol
protocol NVActivityIndicatorAnimationDelegate {
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor)
}
#endif
