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
    
    // Value from 0 to 1. The view will be impressed if its area ratio remains equal to or greater than this value.
    var areaRatioThreshold: Double {
        didSet {
            areaRatioThreshold = areaRatioThreshold.ensureZeroToOneRange()
        }
    }
    
    // Minimum duration time (in seconds) the view must remain visible to be impressed. Value should be positive.
    var durationThreshold: TimeInterval {
        didSet {
            durationThreshold = durationThreshold.ensureNonNegative()
        }
    }
    
    // Detection interval (in seconds). Smaller intervals increase accuracy but consume more resources.
    var detectionInterval: Double {
        didSet {
            detectionInterval = detectionInterval.ensureNonNegative()
        }
    }
    
    // Alpha threshold. Value from 0 to 1. The view will be impressed if its alpha is equal to or greater than this value.
    var alphaThreshold: Double {
        didSet {
            alphaThreshold = alphaThreshold.ensureZeroToOneRange()
        }
    }
    
    // Container view for which the tracking is done. If no value is set the tracking will be done for the root view.
    var trackingContainerView: UIView?
    
    // Insets to reduce the tracked area of the tracking container view, e.g. to exclude area hidden behind opaque navigation bars.
    var trackingInsets: UIEdgeInsets
    
    // Default configuration values
    static let `default` = ViewabilityConfiguration(
        trackingInsets: Defaults.trackingInsets,
        trackingView: Defaults.trackingView,
        areaRatioThreshold: Defaults.areaRatioThreshold,
        durationThreshold: Defaults.durationThreshold,
        detectionInterval: Defaults.detectionInterval,
        alphaThreshold: Defaults.alphaThreshold)
    
    // Initializer with validation
    init(trackingInsets: UIEdgeInsets = Defaults.trackingInsets,
         trackingView: UIView? = Defaults.trackingView,
         areaRatioThreshold: Double = Defaults.areaRatioThreshold,
         durationThreshold: TimeInterval = Defaults.durationThreshold,
         detectionInterval: Double = Defaults.detectionInterval,
         alphaThreshold: Double = Defaults.alphaThreshold) {
        
        // Initialise all stored properties
        self.trackingInsets = trackingInsets
        self.trackingContainerView = trackingView
        self.areaRatioThreshold = areaRatioThreshold
        self.durationThreshold = durationThreshold
        self.detectionInterval = detectionInterval
        self.alphaThreshold = alphaThreshold
        
        // Validate properties
        self.areaRatioThreshold = areaRatioThreshold.ensureZeroToOneRange()
        self.durationThreshold = durationThreshold.ensureNonNegative()
        self.detectionInterval = detectionInterval.ensureNonNegative()
        self.alphaThreshold = alphaThreshold.ensureZeroToOneRange()
    }
}
