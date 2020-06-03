//
//  ObservationCollectionCell.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/31/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import UIKit
import Spring

class ObservationCollectionCell: UICollectionViewCell {
	
	@IBOutlet var climateTypeImageView: UIImageView!
	@IBOutlet var climateValueLabel: UILabel!
	@IBOutlet var hagValueLabel: UILabel!
	@IBOutlet var custombgView: DesignableView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
