//
//  TableVC.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/1/25.
//

import UIKit

class TableVC: UITableViewController {
    
    private let viewabilityManager: ViewabilityManaging
    
    private lazy var impressions: [Impression] = {
        (0..<100).map{ index in Impression(index: index, impressionCompleted: false)}
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
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return impressions.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableViewCell", for: indexPath) as! SimpleTableViewCell
        
        // Remove the cell from tracking when it is reused
        viewabilityManager.stopTracking(of: cell)
        
        // Configure the cell and track its viewability
        viewabilityManager.startTracking(of: cell) { [weak self] in
            guard let self = self else { return }
            
            // Add custom logic
            
            impressions[indexPath.row].impressionCompleted = true
            cell.backgroundColor = impressions[indexPath.row].backgroundColor
            print("Cell \(cell.infoLabel.text!) met viewability criteria.")
        }
        
        let impression = impressions[indexPath.row]
        cell.infoLabel.text = "\(impression.index)"
        cell.backgroundColor = impression.backgroundColor
        
        return cell
    }
}
