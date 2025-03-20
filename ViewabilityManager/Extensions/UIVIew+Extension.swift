//
//  UIVIew+Extension.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/20/25.
//

import UIKit

extension UIView {
    
   func getContainingViewController() -> UIViewController? {
       var responder: UIResponder? = self
       
       while responder != nil {
           if let viewController = responder as? UIViewController {
               return viewController
           }
           
           responder = responder?.next
       }
       
       return nil
   }
}
