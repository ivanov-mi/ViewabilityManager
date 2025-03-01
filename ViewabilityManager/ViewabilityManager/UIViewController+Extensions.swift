//
//  UIViewController+Extensions.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 2/27/25.
//

import UIKit

extension UIViewController {
    
    func startViewabilityTracking(of view: UIView, using manager: ViewabilityManaging, onSuccess: @escaping () -> Void) {
        manager.startViewabilityTracking(of: view, onSuccess: onSuccess)
    }
    
    func stopViewabilityTracking(of view: UIView, using manager: ViewabilityManaging) {
        manager.stopViewabilityTracking(of: view)
    }
}
