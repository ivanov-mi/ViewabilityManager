//
//  ViewabilityManager.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 2/27/25.
//

import UIKit

protocol ViewabilityManaging {
    var config: ViewabilityConfiguration { get }
    
    func startTracking(of view: UIView, onSuccess: @escaping () -> Void)
    func stopTracking(of view: UIView)
}

struct TrackedItem {
    let viewProvider: () -> UIView?
    var impressionStartTime: Date?
    let onSuccessCallback: () -> Void
    var hasCompletedImpression: Bool = false
}

class ViewabilityManager: ViewabilityManaging {
    private(set) var config: ViewabilityConfiguration
    private var trackedItems: [UUID: TrackedItem] = [:]
    private var timer: Timer?
    
    // Starts tracking a view's visibility
    func startTracking(of view: UIView, onSuccess: @escaping () -> Void) {
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
    func stopTracking(of view: UIView) {
        if let id = trackedItems.first(where: { $0.value.viewProvider() == view })?.key {
            removeTrackedItem(id)
        }
    }
    
    init(configuration: ViewabilityConfiguration = .default) {
        self.config = configuration
        initializeTimer()
    }
    
    // Cleans up the timer and its reference on deinitialization
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

private extension ViewabilityManager {
    // Starts the timer for periodic visibility checks
    func initializeTimer() {
        timer = Timer.scheduledTimer(timeInterval: config.detectionInterval, target: self, selector: #selector(checkVisibility), userInfo: nil, repeats: true)
        
        if let timer {
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    // Adds a view to the tracking list
    func addTrackedItem(for view: UIView, onSuccess: @escaping () -> Void) {
        guard !trackedItems.contains(where: { $0.value.viewProvider() === view }) else {
            return
        }
        
        let id = UUID()
        let viewProvider = { [weak view] in view }
        trackedItems[id] = TrackedItem(viewProvider: viewProvider, impressionStartTime: nil, onSuccessCallback: onSuccess)
    }
    
    // Removes a view from the tracking list
    func removeTrackedItem(_ id: UUID) {
        trackedItems.removeValue(forKey: id)
    }
    
    // Checks visibility of tracked views
    @objc func checkVisibility() {
        let now = Date()
        for (id, item) in trackedItems {
            guard let view = item.viewProvider(), view.window != nil else {
                removeTrackedItem(id)
                continue
            }
            
            guard !item.hasCompletedImpression else {
                continue
            }
            
            if isViewVisible(view) {
                verifyImpressionDuration(for: id, at: now)
            } else {
                // Set currentImpressionStart to nil if the view is not visible
                trackedItems[id]?.impressionStartTime = nil
            }
        }
    }
    
    // Determines if a view is visible
    func isViewVisible(_ view: UIView) -> Bool {
        // Ensure the view is part of a window, not hidden and has sufficient alpha
        guard let window = view.window,
              !view.isHidden,
              view.alpha >= config.alphaThreshold else {
            return false
        }
        
        var currentView = view
        var frameInSuperview = view.bounds
        
        // Traverse up the view hierarchy
        while let superview = currentView.superview {
            // Check if the superview is visible and has sufficient alpha
            guard !superview.isHidden,
                  superview.alpha >= config.alphaThreshold else {
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
        let adjustedScreenBounds = UIEdgeInsetsInsetRect(window.screen.bounds, config.trackedScreenInsets)
        let visibleRect = frameInScreen.intersection(adjustedScreenBounds)
        
        // Calculate the ratio of the visible area to the total area
        let visibleArea = visibleRect.width * visibleRect.height
        let totalArea = view.frame.width * view.frame.height
        let visibleRatio = visibleArea / totalArea
        
        return visibleRatio >= config.areaRatioThreshold
    }
    
    // Checks if a view has been visible for the required duration
    func verifyImpressionDuration(for id: UUID, at now: Date) {
        // Initialize currentImpressionStart if it's nil
        if trackedItems[id]?.impressionStartTime == nil {
            trackedItems[id]?.impressionStartTime = now
        }
        
        if let startTime = trackedItems[id]?.impressionStartTime {
            let duration = now.timeIntervalSince(startTime)
            if duration >= config.durationThreshold && !(trackedItems[id]?.hasCompletedImpression ?? true) {
                completeImpression(id)
            }
        }
    }
    
    // Marks a view as having completed a successful impression
    func completeImpression(_ id: UUID) {
        guard var item = trackedItems[id] else {
            return
        }
        
        item.onSuccessCallback()
        item.hasCompletedImpression = true
        item.impressionStartTime = nil
        trackedItems[id] = item
    }
}
