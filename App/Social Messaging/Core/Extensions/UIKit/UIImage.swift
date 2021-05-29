//
//  UIImage.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 11/12/2020.
//

import UIKit

extension UIImage {
    // MARK: - Change resolution
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    // MARK: - Scale
    func makeSquareImageWith(_ edge: CGFloat) -> UIImage {

        let horizontalRatio = edge / self.size.width
        let verticalRatio = edge / self.size.height

        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: edge, height: edge)
        var newImage: UIImage

        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = false
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: newSize.width, height: newSize.height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1)
            self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }

        return newImage
    }

    func resizeImageWith(newSize: CGSize) -> UIImage {

        let horizontalRatio = newSize.width / self.size.width
        let verticalRatio = newSize.height / self.size.height

        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
        var newImage: UIImage

        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = false
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: newSize.width, height: newSize.height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1)
            self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }

        return newImage
    }
    
    // MARK: - File storage.
    /// Save image to file with .png extension.
    /// - The parameter filename doesn't need enter .png extension.
    func saveToFileAsPNGEx(_ fileName: String) {
        do {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let savingUrl = documents.appendingPathComponent("\(fileName).png")
            if let pngData = self.pngData() {
                try pngData.write(to: savingUrl)
            }
        } catch {
            
        }
    }
    
    /// - The parameter filename doesn't need enter .png extension.
    static func loadImageFromFileWithPNGEx(_ fileName: String) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("\(fileName).png")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data.init(contentsOf: fileURL)
                return UIImage(data: data)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
/*
 Usage:
 let image = UIImage(data: try! Data(contentsOf: URL(string:"http://i.stack.imgur.com/Xs4RX.jpg")!))!
 
 let thumb1 = image.resized(withPercentage: 0.1)
 let thumb2 = image.resized(toWidth: 72.0)
 */
