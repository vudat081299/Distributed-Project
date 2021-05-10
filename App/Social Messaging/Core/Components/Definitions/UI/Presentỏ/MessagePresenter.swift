//
//  MessagePresenter.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 24/12/2020.
//

import UIKit

func wait(on viewController: UIViewController?, time: Double,_ handler: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
        handler()
    }
}

class MessagePresenter {
    static func showMessage(message: String, on viewController: UIViewController?, dismissAction: ((UIAlertAction) -> Void)? = nil) {
        weak var vc = viewController
        DispatchQueue.main.async {
          let alertController = UIAlertController(title: "Notice",
                                                  message: message,
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: dismissAction))
          vc?.present(alertController, animated: true)
        }
    }
}

class DidRequestServer {
    static func successful(on viewController: UIViewController?, dismissAction: ((UIAlertAction) -> Void)? = nil, title: String) {
        weak var vc = viewController
        DispatchQueue.main.async {
            vc!.view.endEditing(true)
            let view = SuccessRequestServerView.instanceFromNib(title: title)
            view.frame = CGRect(x: 0, y: 0, width: vc!.view.frame.size.width, height: vc!.view.frame.size.height)
            view.alpha = 0
            vc!.view.addSubview(view)
            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: [.curveEaseIn],
                           animations: { 
                            view.alpha = 1
                           }, completion: nil)
            wait(on: vc!, time: 4.5) {
                UIView.animate(withDuration: 0.3,
                               delay: 0.1,
                               options: [.curveEaseIn],
                               animations: { 
                                view.alpha = 0
                               }, completion: {_ in
                                vc!.navigationController?.popViewController(animated: true)
//                                view.removeFromSuperview()
                               })
            }
        }
    }
}
