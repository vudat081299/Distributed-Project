//
//  ErrorControl.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 11/12/2020.
//

import UIKit

class ErrorPresenter {

    // MARK: - Alert error
  static func showError(message: String, on viewController: UIViewController?, dismissAction: ((UIAlertAction) -> Void)? = nil) {
    weak var vc = viewController
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: "Error",
                                              message: message,
                                              preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: dismissAction))
      vc?.present(alertController, animated: true)
    }
  }
}
