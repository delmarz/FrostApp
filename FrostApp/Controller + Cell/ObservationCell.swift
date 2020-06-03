//
//  ObservationCell.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/31/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import UIKit
import Spring

protocol ObservationCellDelegate {
	func selectedItemInCollectionView(indexPath: IndexPath)
}

class ObservationCell: UITableViewCell {
	
 var delegate: ObservationCellDelegate?
	
	@IBOutlet var dateLabel: DesignableLabel!
	@IBOutlet var timeLabel: DesignableLabel!
	
	@IBOutlet var collectionViewCell: UICollectionView!
	
	var tableViewCellCoordinator: [Int: IndexPath] = [:]
	var observationsCollection: [ObservationsChildDetails]?

	var checked: Bool! {
			didSet {
					if (self.checked == true) {
						self.backgroundColor = .white
					}else{
						self.backgroundColor = .systemGray6
					}
			}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
			checked = false
			collectionViewCell.register(UINib(nibName: "ObservationCollectionCell",  bundle: nil), forCellWithReuseIdentifier: "collectionCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}


extension ObservationCell : UICollectionViewDataSource {
    
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return observationsCollection?.count ?? 0
    }
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ObservationCollectionCell
		let oc = observationsCollection?[indexPath.row]
		if oc?.elementId == "air_temperature" {
			cell.climateTypeImageView.image = UIImage(named: "temperature")
			cell.climateValueLabel.text = "\(oc?.value?.string ?? "") ℃"
			cell.hagValueLabel.text = "\(oc?.level?.value?.string ?? "") m"
		} else if oc?.elementId == "wind_speed" {
			cell.climateTypeImageView.image = UIImage(named: "wind")
			cell.climateValueLabel.text = "\(oc?.value?.string ?? "") m/s"
			cell.hagValueLabel.text = "\(oc?.level?.value?.string ?? "") m"
		}
		return cell
	}
}

extension ObservationCell : UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
			let hardCodedPadding:CGFloat = 5
			let itemWidth = 114 - hardCodedPadding
			let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
			return CGSize(width: itemWidth, height: itemHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("selected collectionViewCell with indexPath: \(indexPath) in tableViewCell with indexPath: \(tableViewCellCoordinator[collectionView.tag]!)")
		delegate?.selectedItemInCollectionView(indexPath: tableViewCellCoordinator[collectionView.tag]!)
		 }
}
