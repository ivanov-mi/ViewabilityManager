//
//  BasicViewController.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/1/25.
//

import UIKit

class BasicViewController: UIViewController {
    
    private let viewabilityManager: ViewabilityManaging
    private lazy var trackedViews: [UIView] = {
        return (0..<5).map { createView(withNumber: $0) }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        layoutTrackedViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startTrackigViewability()
    }
    
    init() {
        viewabilityManager = ViewabilityManager()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BasicViewController {
    
    func createView(withNumber number: Int) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(number)"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    func layoutTrackedViews() {
        trackedViews.forEach { view.addSubview($0) }
        
        // Test data for functionality preview purposes
        NSLayoutConstraint.activate([
            // View 1 - Fully within the frame (more than 50% visibility)
            trackedViews[0].widthAnchor.constraint(equalToConstant: 150),
            trackedViews[0].heightAnchor.constraint(equalToConstant: 150),
            trackedViews[0].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 9),
            trackedViews[0].topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            
            // View 2 - Fully within the frame (more than 50% visibility)
            trackedViews[1].widthAnchor.constraint(equalToConstant: 150),
            trackedViews[1].heightAnchor.constraint(equalToConstant: 150),
            trackedViews[1].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -20),
            trackedViews[1].topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            
            // View 3 - Centered in the frame
            trackedViews[2].widthAnchor.constraint(equalToConstant: 150),
            trackedViews[2].heightAnchor.constraint(equalToConstant: 150),
            trackedViews[2].centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackedViews[2].centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // View 4 - Partially within the frame (less than 50% visibility)
            trackedViews[3].widthAnchor.constraint(equalToConstant: 150),
            trackedViews[3].heightAnchor.constraint(equalToConstant: 150),
            trackedViews[3].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -80),
            trackedViews[3].bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            // View 5 - Partially within the frame (less than 50% visibility)
            trackedViews[4].widthAnchor.constraint(equalToConstant: 150),
            trackedViews[4].heightAnchor.constraint(equalToConstant: 150),
            trackedViews[4].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 85),
            trackedViews[4].bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75),
        ])
    }
    
    // Start cell viewability tracking
    func startTrackigViewability() {
        // Should add custom logic
        /// Test logic for functionality preview purposes
        for index in trackedViews.indices {
            let view = trackedViews[index]
            viewabilityManager.startTracking(of: view) {
                view.backgroundColor = .green
                print("TestView \(index) met viewability criteria.")
            }
        }
    }
}
