//
//  HomeViewController.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/1/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButtons()
    }
    
    @objc func showUIViewController() {
        let viewController = BasicViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func showUITableViewController() {
        let viewController = TableVC()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func showUICollectionViewControllerVertical() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let viewController = CollectionVC(layout: layout)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func showUICollectionViewControllerHorizontal() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let viewController = CollectionVC(layout: layout)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension HomeViewController {
    
    func setupButtons() {
        let buttonTitles = [
            "BasicViewController",
            "UITableViewController",
            "UICollectionViewController - Vertical",
            "UICollectionViewController - Horizontal"]
        let selectors: [Selector] = [
            #selector(showUIViewController),
            #selector(showUITableViewController),
            #selector(showUICollectionViewControllerVertical),
            #selector(showUICollectionViewControllerHorizontal)]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: selectors[index], for: .touchUpInside)
            button.frame = CGRect(x: 20, y: 100 + index * 50, width: 400, height: 40)
            stackView.addArrangedSubview(button)
        }
    }
}
