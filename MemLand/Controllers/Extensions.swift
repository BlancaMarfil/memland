//
//  Extensions.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 19/2/22.
//

import UIKit

extension UIAlertController {
    
    func isValidName(_ name: String) -> Bool {
        return name.count > 0 && name.count <= 20
    }
    
    @objc func textDidChangeInAlert() {
        if let projectName = textFields?.first?.text,
           let action = actions.last {
            action.isEnabled = isValidName(projectName)
        }
    }
}

protocol AlertManagerDelegate {
    func performAlertFunction()
}

struct AlertManager {
    
    var delegate: AlertManagerDelegate?
    
    func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            self.delegate?.performAlertFunction()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        return alert
    }
}
