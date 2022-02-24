//
//  HistoryCell.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 9/2/22.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var sourceImage: UIImageView!
    @IBOutlet weak var targetImage: UIImageView!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var projectNameView: UIView!
    @IBOutlet weak var projectNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // UI
        projectNameView.layer.cornerRadius = 5
        
        wordLabel.numberOfLines = 0
        wordLabel.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
