//
//  StationCell.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/30/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import UIKit

class StationCell: UITableViewCell {
	
	@IBOutlet var stationLabel: UILabel!
	@IBOutlet var locationNameLabel: UILabel!
	@IBOutlet var countryLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
