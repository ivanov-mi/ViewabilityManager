//
//  TableVC.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/1/25.
//

import UIKit

class TableVC: UITableViewController {
    
    private let viewabilityManager: ViewabilityManaging
    
    private lazy var trackedViews: [TrackedView] = {
        (0..<100).map{ index in TrackedView(index: index, impressionCompleted: false)}
    }()
    
    init() {
        viewabilityManager = ViewabilityManager()
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: "SimpleTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
// Functionality preview logic - reducing the vertical size of tracked screen to ignore the area under the navigation and status bars.
        adjustTrackedScreenSizeToCompensateAreaUnderNavigationBar()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackedViews.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableViewCell", for: indexPath) as! SimpleTableViewCell
        
        // Remove the cell from tracking when it is reused
        /**
         This method must be called every time in
         1. UICollectionView: `func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell`
         2. UITableView: `func cellForRow(at indexPath: IndexPath) -> UITableViewCell?`
         3. or your custom implementation methods.
         Non-calling may cause abnormal impression.
         */
        viewabilityManager.stopTracking(of: cell)
        
        // Start cell viewability tracking
        viewabilityManager.startTracking(of: cell) { [weak self] in
            guard let self = self else { return }
            
            // Should add custom logic
            /// Test logic for functionality preview purposes
            trackedViews[indexPath.row].impressionCompleted = true
            cell.backgroundColor = trackedViews[indexPath.row].backgroundColor
            print("Cell \(cell.infoLabel.text!) met viewability criteria.")
        }
        
        // Should add custom logic
        /// Test logic for functionality preview purposes
        let impression = trackedViews[indexPath.row]
        cell.infoLabel.text = "\(impression.index)"
        cell.backgroundColor = impression.backgroundColor
        
        return cell
    }
}

private extension TableVC {
    
    func adjustTrackedScreenSizeToCompensateAreaUnderNavigationBar() {
        guard let navigationController = self.navigationController else {
            return
        }
        let navigationBarHeight = navigationController.navigationBar.frame.height
        
        var statusBarHeight: CGFloat = 0
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        }
        
        let verticalOffset = navigationBarHeight + statusBarHeight
        let insets = UIEdgeInsets(top: verticalOffset, left: 0, bottom: 0, right: 0)
        viewabilityManager.config.trackedScreenInsets = insets
    }
}
