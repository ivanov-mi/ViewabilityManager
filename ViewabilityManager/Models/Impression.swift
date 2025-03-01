//
//  Impression.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/1/25.
//

import UIKit

struct Impression {
    let index: Int
    var impressionCompleted: Bool
    
    var backgroundColor: UIColor {
        impressionCompleted ? .green : .red
    }
}
