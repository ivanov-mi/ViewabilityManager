//
//  Double+Extensions.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/20/25.
//

import Foundation

extension Double {
    
    func ensureZeroToOneRange() -> Double {
        return min(max(self, 0), 1)
    }
    
    func ensureNonNegative() -> Double {
        return max(self, 0)
    }
}
