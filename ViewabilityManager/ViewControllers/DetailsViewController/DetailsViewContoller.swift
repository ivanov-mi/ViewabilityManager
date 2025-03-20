//
//  Untitled.swift
//  ViewabilityManager
//
//  Created by Martin Ivanov on 3/20/25.
//

import UIKit

class DetailsViewController: UIViewController {
   
   private var detailLabel: UILabel!
   var detailText: String?
   
   override func viewDidLoad() {
       super.viewDidLoad()
       
       view.backgroundColor = .white
       
       detailLabel = UILabel()
       detailLabel.translatesAutoresizingMaskIntoConstraints = false
       detailLabel.text = detailText
       detailLabel.textAlignment = .center
       detailLabel.font = UIFont.systemFont(ofSize: 24)
       
       view.addSubview(detailLabel)
       
       NSLayoutConstraint.activate([
           detailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           detailLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
       ])
   }
}
