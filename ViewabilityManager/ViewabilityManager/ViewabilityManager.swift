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

struct TrackedItem {
    let view: () -> UIView?
    var currentImpressionStart: Date?
    let successfulImpressionCallback: () -> Void
    var impressionSuccessfullyCompleted: Bool = false
}

class ViewabilityManager: ViewabilityManaging {
    private let configuration: ViewabilityConfiguration
    private var trackedItems: [UUID: TrackedItem] = [:]
    private var timer: Timer?
    
    // Starts tracking a view's visibility
    func startViewabilityTracking(of view: UIView, onSuccess: @escaping () -> Void) {
        addTrackedItem(for: view, onSuccess: onSuccess)
    }
    
    // Stops tracking a view's visibility
    /**
     This method must be called every time in
     1. UICollectionView: `func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell`
     2. UITableView: `func cellForRow(at indexPath: IndexPath) -> UITableViewCell?`
     3. or your custom implementation methods.
     Non-calling may cause abnormal impression.
     */
    func stopViewabilityTracking(of view: UIView) {
        if let id = trackedItems.first(where: { $0.value.view() == view })?.key {
            removeTrackedItem(id)
        }
    }
    
    init(configuration: ViewabilityConfiguration = .default) {
        self.configuration = configuration
        startTimer()
    }
    
    // Cleans up the timer and its reference on deinitialization
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

private extension ViewabilityManager {
    // Starts the timer for periodic visibility checks
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: configuration.detectionInterval, target: self, selector: #selector(checkViewability), userInfo: nil, repeats: true)
        
        if let timer {
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    // Adds a view to the tracking list
    func addTrackedItem(for view: UIView, onSuccess: @escaping () -> Void) {
        guard !trackedItems.contains(where: { $0.value.view() === view }) else {
            return
        }
        
        let id = UUID()
        let viewClosure = { [weak view] in view }
        trackedItems[id] = TrackedItem(view: viewClosure, currentImpressionStart: nil, successfulImpressionCallback: onSuccess)
    }
    
    // Removes a view from the tracking list
    func removeTrackedItem(_ id: UUID) {
        trackedItems.removeValue(forKey: id)
    }
    
    // Checks visibility of tracked views
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
    
    // Determines if a view is visible based on hierarchy and settings
    func isTrackedViewVisible(_ view: UIView) -> Bool {
        // Ensure the view is part of a window, not hidden, and has sufficient alpha
        guard let window = view.window,
              view.isHidden == false,
              view.alpha >= configuration.alphaThreshold else {
            return false
        }
        
        var currentView = view
        var frameInSuperview = view.bounds
        
        // Traverse up the view hierarchy
        while let superview = currentView.superview {
            // Check if the superview is visible and has sufficient alpha
            guard !superview.isHidden,
                  superview.alpha >= configuration.alphaThreshold else {
                return false
            }
            
            // Convert the view's frame to the superview's coordinate system
            frameInSuperview = currentView.convert(frameInSuperview, to: superview)
            
            // If the superview clips its bounds, intersect the frame with the superview's bounds
            if currentView.clipsToBounds {
                frameInSuperview = frameInSuperview.intersection(currentView.frame)
            }
            
            // If the frame is empty, the view is not visible
            guard !frameInSuperview.isEmpty else {
                return false
            }
            
            // Move up to the next superview
            currentView = superview
        }
        
        // Convert the final frame to the screen's coordinate system
        let frameInWindow = frameInSuperview
        let frameInScreen = CGRect.init(x: frameInWindow.origin.x + window.frame.origin.x,
                                        y: frameInWindow.origin.y + window.frame.origin.y,
                                        width: frameInWindow.width,
                                        height: frameInWindow.height)
        
        // Apply insets to the screen bounds to adjust the visible area
        let adjustedScreenBounds = UIEdgeInsetsInsetRect(window.screen.bounds, configuration.trackedScreenInsets)
        let visibleRect = frameInScreen.intersection(adjustedScreenBounds)
        
        // Calculate the ratio of the visible area to the total area
        let visibleArea = visibleRect.width * visibleRect.height
        let totalArea = view.frame.width * view.frame.height
        let visibleRatio = visibleArea / totalArea
        
        return visibleRatio >= configuration.areaRatioThreshold
    }
    
    // Checks if a view has been visible for the required duration
    func checkDuration(for id: UUID, at now: Date) {
        // Initialize currentImpressionStart if it's nil
        if trackedItems[id]?.currentImpressionStart == nil {
            trackedItems[id]?.currentImpressionStart = now
        }
        
        if let currentImpressionStart = trackedItems[id]?.currentImpressionStart {
            let visibilityDuration = now.timeIntervalSince(currentImpressionStart)
            if visibilityDuration >= configuration.durationThreshold && !(trackedItems[id]?.impressionSuccessfullyCompleted ?? true) {
                trackedItemSuccessfulImpression(id)
            }
        }
    }
    
    // Marks a view as having completed a successful impression
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
