//
//  CrosswordTableViewCell.swift
//  Crossword
//
//  Created by Brendan Krekeler on 7/31/19.
//  Copyright © 2019 Zukosky, Jonah. All rights reserved.
//

import UIKit

class CrosswordTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
