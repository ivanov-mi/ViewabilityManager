//
//  ViewabilityConfiguration.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/14/25.
//

import UIKit

struct ViewabilityConfiguration {
    
    // Default values for configuration parameters
    enum Defaults {
        static let areaRatioThreshold = 0.5
        static let durationThreshold = 1.0
        static let detectionInterval = 0.1
        static let alphaThreshold = 0.5
        static let trackingView: UIView? = nil
        static let trackingInsets: UIEdgeInsets = .zero
    }
    
    // Private storage for configuration parameters
    private var _areaRatioThreshold: Double = Defaults.areaRatioThreshold
    private var _durationThreshold: TimeInterval = Defaults.durationThreshold
    private var _detectionInterval: Double = Defaults.detectionInterval
    private var _alphaThreshold: Double = Defaults.alphaThreshold
    private var _trackingView: UIView? = Defaults.trackingView
    private var _trackingInsets: UIEdgeInsets = Defaults.trackingInsets
    
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
    
    // Container view for which the tracking is done. If no value is set the tracking will be done for the root view.
    var trackingView: UIView? {
        get { _trackingView }
        set { _trackingView = newValue }
    }
    
    // Insets to reduce the tracked area of the tracking view, e.g. to exclude area hidden behind opaque navigation bars.
    var trackingInsets: UIEdgeInsets {
        get { _trackingInsets }
        set { _trackingInsets = newValue }
    }
    
    // Default configuration values
    static let `default` = ViewabilityConfiguration(
        areaRatioThreshold: Defaults.areaRatioThreshold,
        durationThreshold: Defaults.durationThreshold,
        detectionInterval: Defaults.detectionInterval,
        alphaThreshold: Defaults.alphaThreshold,
        trackingInsets: Defaults.trackingInsets,
        trackingView: Defaults.trackingView
    )
    
    // Initializer
    init(areaRatioThreshold: Double = Defaults.areaRatioThreshold,
         durationThreshold: TimeInterval = Defaults.durationThreshold,
         detectionInterval: Double = Defaults.detectionInterval,
         alphaThreshold: Double = Defaults.alphaThreshold,
         trackingInsets: UIEdgeInsets = Defaults.trackingInsets,
         trackingView: UIView? = Defaults.trackingView) {
        self.areaRatioThreshold = areaRatioThreshold
        self.durationThreshold = durationThreshold
        self.detectionInterval = detectionInterval
        self.alphaThreshold = alphaThreshold
        self.trackingInsets = trackingInsets
        self.trackingView = trackingView
    }
}

