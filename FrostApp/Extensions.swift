//
//  Extensions.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/31/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import Foundation
import MBProgressHUD
import Spring

extension UIViewController {
	
	func showHUDWithNavigation(progressLabel:String){
		if let nav = navigationController?.view {
			let progressHUD = MBProgressHUD.showAdded(to: nav, animated: true)
			progressHUD.label.text = progressLabel
			progressHUD.label.font = UIFont.boldSystemFont(ofSize: 14)
		}
	}
	
	func dismissHUDWithNavigation(isAnimated:Bool) {
		if let nav = navigationController?.view {
			MBProgressHUD.hide(for: nav, animated: isAnimated)
		}
	}
	
	func showHUD(progressLabel:String){
		let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
		progressHUD.label.text = progressLabel
		progressHUD.label.font = UIFont.boldSystemFont(ofSize: 14)
	}

	func dismissHUD(isAnimated:Bool) {
			MBProgressHUD.hide(for: self.view, animated: isAnimated)
	}
	
	func alertWithoutNav(message: String, title: String = "Forst App") {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
			self.dismissHUD(isAnimated: true)
		}
		alertController.addAction(OKAction)
		self.present(alertController, animated: true, completion: nil)
	}
	
	func alert(message: String, title: String = "Frost App") {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
				self.dismissHUDWithNavigation(isAnimated: true)
		}
		alertController.addAction(OKAction)
		self.present(alertController, animated: true, completion: nil)
	}
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension String {
	
	static func getStringTimeFormat(date: String) -> String {
		let datee = dateFromString(date: date, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
		return stringFromDate(date: datee as NSDate, format: "h:mm a")
	}
	
	static func getStringDateFormat(date: String) -> String {
		let datee = dateFromString(date: date, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
		return stringFromDate(date: datee as NSDate, format: "E, dd MMM yyyy")
	}
}

extension UITableView {
	
    func scrollToBottom(animated: Bool = true) {
        let sections = self.numberOfSections
			let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0){
					self.scrollToRow(at: NSIndexPath(row: rows - 1, section: sections - 1) as IndexPath, at: .bottom, animated: true)
        }
    }
}


