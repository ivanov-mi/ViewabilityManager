//
//  ViewabilityManager.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 2/27/25.
//

import UIKit

protocol ViewabilityManaging {
    var config: ViewabilityConfiguration { get set }
    
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
    private var trackedItems: [UUID: TrackedItem] = [:]
    private var timer: Timer?
    
    var config: ViewabilityConfiguration {
        didSet {
            configurationDidChange()
        }
    }
    
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
        initializeTimer(with: configuration.detectionInterval)
    }
    
    // Cleans up the timer and its reference on deinitialization
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

private extension ViewabilityManager {
    
    // Starts the timer for periodic visibility checks
    func initializeTimer(with timeInterval: TimeInterval) {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(checkVisibility), userInfo: nil, repeats: true)
        
        if let timer {
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    // Handle changes in ViewabilityManager configuration
    func configurationDidChange() {
        
        // Invalidate the existing timer
        timer?.invalidate()
        
        // Start a new timer with the updated configuration
        initializeTimer(with: config.detectionInterval)
        
        // Update impression start times for views that are still being tracked
        trackedItems.forEach { id, item in
            if item.impressionStartTime != nil && !item.hasCompletedImpression {
                trackedItems[id]?.impressionStartTime = .now
            }
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
        
        // Check if tracking container view is part from the visible view controller hierarchy
        /// In case a tracking container view is not set the check is irrelevant
        if let referenceView = config.trackingContainerView {
            guard let viewController = referenceView.getContainingViewController(),
                  viewController.isVisibleAndTopmost else {
                invalidateTrackedItems()
                return
            }
        }
        
        let now = Date()
        for (id, item) in trackedItems {
            guard let view = item.viewProvider() else {
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
        
        // Check if the view's view controller is visible and topmost
        guard let viewController = view.getContainingViewController(),
              viewController.isVisibleAndTopmost else {
            return false
        }
        
        var frameInSuperview = view.bounds
        
        // Traverse up the view hierarchy to check visibility
        guard isViewHierarchyVisible(view: view, frameInSuperview: &frameInSuperview) else {
            return false
        }
        
        // Convert the final tracked frame to the screen's coordinate system
        let visibleRect = calculateVisibleRect(frameInSuperview: frameInSuperview, window: window)
        
        // Check if the visible rectangle is valid
        guard !visibleRect.isNull else {
            return false
        }
        
        // Calculate the visible ratio
        return isVisibleRatioValid(visibleRect: visibleRect, view: view)
    }
    
    // Traverse the view hierarchy to check visibility
    func isViewHierarchyVisible(view: UIView, frameInSuperview: inout CGRect) -> Bool {
        var currentView = view
        
        // Traverse up the view hierarchy
        while let superview = currentView.superview {
            guard !superview.isHidden && superview.alpha >= config.alphaThreshold else {
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
        
        return true
    }
    
    // Calculate the visible rectangle in the window's coordinate system
    func calculateVisibleRect(frameInSuperview: CGRect, window: UIWindow) -> CGRect {
        var visibleRect = CGRect(
            x: frameInSuperview.origin.x + window.frame.origin.x,
            y: frameInSuperview.origin.y + window.frame.origin.y,
            width: frameInSuperview.width,
            height: frameInSuperview.height
        )
        
        // If a tracking container view is specified in the configuration, adjust the visible area
        if let trackingView = config.trackingContainerView,
           let trackingViewWindow = trackingView.window,
           trackingViewWindow == window {
            let trackingViewInWindow = trackingView.convert(trackingView.bounds, to: window)
            visibleRect = visibleRect.intersection(trackingViewInWindow)
        }
        
        // If insets are specified apply them to the tracking container view bounds to adjust the visible area
        if config.trackingInsets != .zero {
            let adjustedScreenBounds = UIEdgeInsetsInsetRect(window.screen.bounds, config.trackingInsets)
            visibleRect = visibleRect.intersection(adjustedScreenBounds)
        }
        
        return visibleRect
    }
    
    // Check if the visible ratio meets the required threshold
    func isVisibleRatioValid(visibleRect: CGRect, view: UIView) -> Bool {
        let visibleArea = visibleRect.width * visibleRect.height
        let totalArea = view.frame.width * view.frame.height
        let visibleRatio = visibleArea / totalArea
        
        // Define a 1% margin to the required ratio to account for floating-point precision issues
        let thresholdMargin = 0.01
        
        // Check if the visible ratio meets threshold within the margin
        return visibleRatio >= config.areaRatioThreshold || abs(visibleRatio - config.areaRatioThreshold) <= thresholdMargin
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
    
    // Invalidate tracked items by resetting their impression start time
    func invalidateTrackedItems() {
        trackedItems.forEach { id, item in
            if item.impressionStartTime != nil && !item.hasCompletedImpression {
                trackedItems[id]?.impressionStartTime = nil
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
