//
//  ServerTableViewCell.swift
//  Minetracker
//
//  Created by iD Student on 7/16/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit

class ServerTableViewCell: UITableViewCell {

    @IBOutlet weak var faviconLabel: UIImageView!
    @IBOutlet weak var networkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            
        }
    }

}
