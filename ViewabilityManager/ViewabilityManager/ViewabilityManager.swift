//
//  ViewabilityManager.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 2/27/25.
//

import UIKit

protocol ViewabilityManaging {
    func startViewabilityTracking(of view: UIView, onSuccess: @escaping () -> Void)
    func stopViewabilityTracking(of view: UIView)
}

enum ViewabilityDefaults {
    static let areaRatioThreshold = 0.5
    static let durationThreshold: TimeInterval = 1.0
    static let numberOfDetectionsPerDuration = 10.0
    static let alphaThreshold: Double = 0.5
    static let trackedScreenInsets: UIEdgeInsets = .zero
}

struct TrackedItem {
    let view: () -> UIView?
    var currentImpressionStart: Date?
    let successfulImpressionCallback: () -> Void
    var impressionSuccessfullyCompleted: Bool = false
}

class ViewabilityManager: ViewabilityManaging {
    private var trackedItems: [UUID: TrackedItem] = [:]
    private var timer: Timer?
    private let areaRatioThreshold: Double
    private let durationThreshold: TimeInterval
    private let detectionInterval: Double
    private let alphaThreshold: Double
    private let trackedScreenInsets: UIEdgeInsets
    
    func startViewabilityTracking(of view: UIView, onSuccess: @escaping () -> Void) {
        addTrackedItem(for: view, onSuccess: onSuccess)
    }
    
    func stopViewabilityTracking(of view: UIView) {
        if let id = trackedItems.first(where: { $0.value.view() == view })?.key {
            removeTrackedItem(id)
        }
    }
    
    init(areaRatioThreshold: Double = ViewabilityDefaults.areaRatioThreshold,
         durationThreshold: TimeInterval = ViewabilityDefaults.durationThreshold,
         alphaThreshold: Double = ViewabilityDefaults.alphaThreshold,
         detectionInterval: Double? = nil,
         trackedScreenInsets: UIEdgeInsets = ViewabilityDefaults.trackedScreenInsets) {
        self.areaRatioThreshold = areaRatioThreshold
        self.durationThreshold = durationThreshold
        self.alphaThreshold = alphaThreshold
        
        // If detection interval is not provided it will be set a based on the default numberOfDetectionsPerDuration value
        self.detectionInterval = detectionInterval ?? (durationThreshold / ViewabilityDefaults.numberOfDetectionsPerDuration)
        self.trackedScreenInsets = trackedScreenInsets
        
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

private extension ViewabilityManager {
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: detectionInterval, target: self, selector: #selector(checkViewability), userInfo: nil, repeats: true)
        
        if let timer {
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    func addTrackedItem(for view: UIView, onSuccess: @escaping () -> Void) {
        guard !trackedItems.contains(where: { $0.value.view() === view }) else {
            return
        }
        
        let id = UUID()
        let viewClosure = { [weak view] in view }
        trackedItems[id] = TrackedItem(view: viewClosure, currentImpressionStart: nil, successfulImpressionCallback: onSuccess)
    }
    
    func removeTrackedItem(_ id: UUID) {
        trackedItems.removeValue(forKey: id)
    }
    
    @objc func checkViewability() {
        let now = Date()
        for (id, trackedItem) in trackedItems {
            guard let view = trackedItem.view(), view.window != nil else {
                removeTrackedItem(id)
                continue
            }
            
            guard !trackedItem.impressionSuccessfullyCompleted else {
                continue
            }
            
            if isTrackedViewVisible(view) {
                checkDuration(for: id, at: now)
            } else {
                // Set currentImpressionStart to nil if the view is not visible
                trackedItems[id]?.currentImpressionStart = nil
            }
        }
    }
    
    func isTrackedViewVisible(_ view: UIView) -> Bool {
        guard let window = view.window,
              view.isHidden == false,
              view.alpha >= alphaThreshold else {
            return false
        }
        
        var currentView = view
        var frameInSuperview = view.bounds
        
        while let superview = currentView.superview {
            guard !superview.isHidden,
                  superview.alpha >= alphaThreshold else {
                return false
            }
            
            frameInSuperview = currentView.convert(frameInSuperview, to: superview)
            if currentView.clipsToBounds {
                frameInSuperview = frameInSuperview.intersection(currentView.frame)
            }
            
            guard !frameInSuperview.isEmpty else {
                return false
            }
            
            currentView = superview
        }
        
        let frameInWindow = frameInSuperview
        let frameInScreen = CGRect.init(x: frameInWindow.origin.x + window.frame.origin.x,
                                        y: frameInWindow.origin.y + window.frame.origin.y,
                                        width: frameInWindow.width,
                                        height: frameInWindow.height)
        
        let adjustedScreenBounds = UIEdgeInsetsInsetRect(window.screen.bounds, trackedScreenInsets)
        let visibleRect = frameInScreen.intersection(adjustedScreenBounds)
        
        let visibleArea = visibleRect.width * visibleRect.height
        let totalArea = view.frame.width * view.frame.height
        let visibleRatio = visibleArea / totalArea
        
        return visibleRatio >= areaRatioThreshold
    }
    
    func isViewHierarchyVisibleWithAlpha(_ view: UIView) -> Bool {
        var currentView: UIView? = view
        
        while let viewToCheck = currentView {
            if viewToCheck.isHidden || viewToCheck.alpha < alphaThreshold {
                return false
            }
            
            currentView = viewToCheck.superview
        }
        
        return true
    }
    
    func isAreaRatioSatisfied(viewFrame: CGRect, within visibleRect: CGRect) -> Bool {
        let intersection = visibleRect.intersection(viewFrame)
        let visibleArea = intersection.width * intersection.height
        let totalArea = viewFrame.width * viewFrame.height
        return (visibleArea / totalArea) >= areaRatioThreshold
    }
    
    func checkDuration(for id: UUID, at now: Date) {
        // Initialize currentImpressionStart if it's nil
        if trackedItems[id]?.currentImpressionStart == nil {
            trackedItems[id]?.currentImpressionStart = now
        }
        
        if let currentImpressionStart = trackedItems[id]?.currentImpressionStart {
            let visibilityDuration = now.timeIntervalSince(currentImpressionStart)
            if visibilityDuration >= durationThreshold && !(trackedItems[id]?.impressionSuccessfullyCompleted ?? true) {
                trackedItemSuccessfulImpression(id)
            }
        }
    }
    
    func trackedItemSuccessfulImpression(_ id: UUID) {
        guard var trackedItem = trackedItems[id] else {
            return
        }
        
        trackedItem.successfulImpressionCallback()
        trackedItem.impressionSuccessfullyCompleted = true
        trackedItem.currentImpressionStart = nil
        trackedItems[id] = trackedItem
    }
}
