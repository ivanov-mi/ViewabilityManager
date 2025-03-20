//
//  UIViewController+Extensions.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/20/25.
//

import UIKit

extension UIViewController {
    
   var isVisibleAndTopmost: Bool {
       // Check if the view is loaded and part of the window hierarchy
       guard isViewLoaded, view.window != nil else {
           return false
       }
       
       // Check if it is the topmost view controller in a navigation stack
       if let navigationController = navigationController {
           return navigationController.visibleViewController === self
       }
       
       // Check if it is the presented view controller
       if let presentedVC = presentingViewController?.presentedViewController {
           return presentedVC === self
       }
       
       // Check if it is the topmost view controller in a tab bar controller
       if let tabBarController = tabBarController {
           return tabBarController.selectedViewController === self
       }
       
       return true
   }
}
