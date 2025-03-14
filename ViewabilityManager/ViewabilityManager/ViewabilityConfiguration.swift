//
//  ViewabilityConfiguration.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/14/25.
//

import UIKit

class ViewabilityConfiguration {
    
    // Default values for configuration parameters
    enum Defaults {
        static let areaRatioThreshold = 0.5
        static let durationThreshold = 1.0
        static let detectionInterval = 0.1
        static let alphaThreshold = 0.5
        static let trackedScreenInsets: UIEdgeInsets = .zero
    }
    
    // Private storage for configuration parameters
    private var _areaRatioThreshold: Double = Defaults.areaRatioThreshold
    private var _durationThreshold: TimeInterval = Defaults.durationThreshold
    private var _detectionInterval: Double = Defaults.detectionInterval
    private var _alphaThreshold: Double = Defaults.alphaThreshold
    private var _trackedScreenInsets: UIEdgeInsets = Defaults.trackedScreenInsets
    
    // Value from 0 to 1. The view will be impressed if its area ratio remains equal to or greater than this value.
    var areaRatioThreshold: Double {
        get { _areaRatioThreshold }
        set { _areaRatioThreshold = min(max(newValue, 0), 1) }
    }
    
    // Minimum duration time (in seconds) the view must remain visible to be impressed. Value should be positive.
    var durationThreshold: TimeInterval {
        get { _durationThreshold }
        set { _durationThreshold = max(newValue, 0) }
    }
    
    // Detection interval (in seconds). Smaller intervals increase accuracy but consume more resources.
    var detectionInterval: Double {
        get { _detectionInterval }
        set { _detectionInterval = max(newValue, 0) }
    }
    
    // Alpha threshold. Value from 0 to 1. The view will be impressed if its alpha is equal to or greater than this value.
    var alphaThreshold: Double {
        get { _alphaThreshold }
        set { _alphaThreshold = min(max(newValue, 0), 1) }
    }
    
    // Insets to reduce the tracked area of the screen, e.g., to exclude area behind opaque navigation bars.
    var trackedScreenInsets: UIEdgeInsets {
        get { _trackedScreenInsets }
        set { _trackedScreenInsets = newValue }
    }
    
    // Default configuration values
    static let `default` = ViewabilityConfiguration(
        areaRatioThreshold: Defaults.areaRatioThreshold,
        durationThreshold: Defaults.durationThreshold,
        detectionInterval: Defaults.detectionInterval,
        alphaThreshold: Defaults.alphaThreshold,
        trackedScreenInsets: Defaults.trackedScreenInsets
    )
    
    // Initializer
    init(areaRatioThreshold: Double = Defaults.areaRatioThreshold,
         durationThreshold: TimeInterval = Defaults.durationThreshold,
         detectionInterval: Double = Defaults.detectionInterval,
         alphaThreshold: Double = Defaults.alphaThreshold,
         trackedScreenInsets: UIEdgeInsets = Defaults.trackedScreenInsets) {
        self.areaRatioThreshold = areaRatioThreshold
        self.durationThreshold = durationThreshold
        self.detectionInterval = detectionInterval
        self.alphaThreshold = alphaThreshold
        self.trackedScreenInsets = trackedScreenInsets
    }
}

