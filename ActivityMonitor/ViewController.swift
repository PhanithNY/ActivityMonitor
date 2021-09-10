//
//  ViewController.swift
//  ActivityMonitor
//
//  Created by Phanith on 10/9/21.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let titleLabel = UILabel()
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.text = "After 10 seconds of inactivity will reach timeout."
    titleLabel.frame = view.bounds.insetBy(dx: 40, dy: 40)
    view.addSubview(titleLabel)
    
    view.backgroundColor = .white
    IdleActivityMonitor.onTimeout { [unowned self] in
      let alertController = UIAlertController(title: "Timeout", message: "Reached 10 seconds timeout.", preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(alertController, animated: true, completion: nil)
    }
    IdleActivityMonitor.startMonitoring()
  }
}

