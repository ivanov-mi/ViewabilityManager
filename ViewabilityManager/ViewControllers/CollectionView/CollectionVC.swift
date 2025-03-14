//
//  ViewController.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 2/27/25.
//

import UIKit

class CollectionVC: UICollectionViewController {
    
    private let viewabilityManager: ViewabilityManaging
    
    private lazy var impressions: [Impression] = {
        (0..<25).map{ index in Impression(index: index, impressionCompleted: false)}
    }()
    
    init(layout: UICollectionViewFlowLayout) {
        viewabilityManager = ViewabilityManager()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(SimpleCollectionViewCell.self, forCellWithReuseIdentifier: "SimpleCollectionViewCell")
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        setupFlowLayout()
    }
    
    private func setupFlowLayout() {
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView?.setCollectionViewLayout(layout, animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return impressions.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimpleCollectionViewCell", for: indexPath) as! SimpleCollectionViewCell
        
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

extension CollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Randomizer.randomSizeIn()
    }
}

