//
//  FloatingViewController.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/30/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import UIKit
import Spring


protocol FloatingViewControllerDelegate {
	func selectedDateItem(at index: Int)
	func observerDatePickerBehaviorAnimation(listOfObservations: ObservationsResponse)
}

class FloatingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ObservationCellDelegate, UITextFieldDelegate {
	
	@IBOutlet var handleArea: DesignableView!
	@IBOutlet var arrowImageView: UIImageView!
	@IBOutlet var countryLabel: UILabel!
	@IBOutlet var locationNameLabel: UILabel!
	@IBOutlet var longAndLatLAbel: UILabel!
	@IBOutlet var municipalityLabel: UILabel!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var selectedDateTextField: DesignableTextField!
	@IBOutlet var selectedToDateTextField: DesignableTextField!
	

	var observationDetail: [ObservationsDetails]?
	var listOfObservations: ObservationsResponse?
	var lastIndexPath: IndexPath?
	var delegate: FloatingViewControllerDelegate?
	let datePickerFromTime = UIDatePicker()
	let datePickerToTime = UIDatePicker()
	var selectedDate = Date()
	var selectedToDate = Date()
	var stationId = String()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupData()
	}
	
	// MARK: - IBAction

	@IBAction func updateBtnPressed(_ sender: DesignableButton) {
		updatingObservationData(stationID: "", dateStringFormat: getValiTimeSeriesString())
	}
	
	// MARK: - Helper Methods
	
	fileprivate func setupData() {
		tableView.register(UINib(nibName: "ObservationCell", bundle: nil), forCellReuseIdentifier: "observationCell")
		if 	let weatherIndex =  observationDetail?.first?.observations?.firstIndex(where: { ($0.elementId == "boolean_fair_weather(cloud_area_fraction P1D)")}) {
			observationDetail?[0].observations?.remove(at: weatherIndex)
		}
		selectedDateTextField.delegate = self
		selectedToDateTextField.delegate = self
		updateSelectedDate(index: 0)
		tableView.reloadData()
	}
	
	fileprivate func updateSelectedDate(index: Int) {
		let date = observationDetail?[index].referenceTime ?? ""
		let initialDate = dateFromString(date: date, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
		selectedDate = initialDate
		selectedToDate = initialDate
		selectedDateTextField.text = stringFromDate(date: selectedDate as NSDate, format: "MMM dd, yyyy")
		selectedToDateTextField.text = ""
	}
	
	fileprivate func showDatePickerFromDate(title: String, textField: UITextField) {
		 let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: 44.0)))
			let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedFromDate))
			let titleButton = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
			titleButton.isEnabled = false
			titleButton.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .disabled)
			let fixed = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
			fixed.width = 90
			toolbar.setItems([doneBtn, fixed, titleButton], animated: true)
			textField.inputAccessoryView = toolbar
			textField.inputView = datePickerFromTime
			datePickerFromTime.datePickerMode = .date
			datePickerFromTime.date = selectedDate
	}
	
	fileprivate func showDatePickerToDate(title: String, textField: UITextField) {
		 let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: 44.0)))
			let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedToDate))
			let titleButton = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
			titleButton.isEnabled = false
			titleButton.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .disabled)
			let fixed = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
			fixed.width = 90
			toolbar.setItems([doneBtn, fixed, titleButton], animated: true)
			textField.inputAccessoryView = toolbar
			textField.inputView = datePickerToTime
			datePickerToTime.datePickerMode = .date
			if selectedToDateTextField.text == "" {
				datePickerToTime.date = selectedDate
			} else {
				datePickerToTime.date = selectedToDate
			}
			datePickerToTime.minimumDate = selectedDate
	}
	
	@objc func donePressedFromDate() {
			selectedDateTextField.text = formatDate(date: datePickerFromTime.date)
			selectedDate = datePickerFromTime.date
			selectedToDate = datePickerFromTime.date
			view.endEditing(true)
	}

	@objc func donePressedToDate() {
			selectedToDateTextField.text =  formatDate(date: datePickerToTime.date)
			selectedToDate = datePickerToTime.date
			view.endEditing(true)
	}
	
	fileprivate func formatDate (date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter.string(from: date)
	}
	
	fileprivate func getValiTimeSeriesString() -> String {
			view.endEditing(true)
			let differenceDateInt = Calendar.current.dateComponents([.day], from: selectedDate, to: selectedToDate).day!
			let dateInt = differenceDateInt + 1
			let finalDateInt = dateInt + dateInt
			var offsetTimeString = ""
			var offsetDateString = "R" + finalDateInt.string
			if differenceDateInt == 0 {
				offsetTimeString = "PT01H"
				offsetDateString = "R14"
				selectedToDateTextField.text = ""
			} else {
				offsetTimeString = "PT12H"
			}
			let fromText = stringFromDate(date: selectedDate as NSDate, format: "yyyy-MM-dd")
			return  offsetDateString + "/" + fromText + "/" + fromText + "/" + offsetTimeString
	}
	
	fileprivate func updatingObservationData(stationID: String, dateStringFormat: String) {
		let observation = NetworkManager()
		observation.getObservations(stationID: "SN18700", dateRangeFormat: dateStringFormat) { (res) in
			switch res {
			case .failure(let error):
				DispatchQueue.main.async {
					self.alertWithoutNav(message: error.localizedDescription)
				}
			case .success(let observation):
				self.listOfObservations = observation
				DispatchQueue.main.async {
					self.observationDetail = observation.data
					self.tableView.reloadData()
					self.delegate?.observerDatePickerBehaviorAnimation(listOfObservations: self.listOfObservations!)
				}
			}
		}
	}
	
	// MARK: - UITextfield Delegate
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == selectedDateTextField {
			showDatePickerFromDate(title: "From Date", textField: selectedDateTextField)
		} else {
			showDatePickerToDate(title: "To Date", textField: selectedToDateTextField)
		}
	}
	
	// MARK: - UITableView DataSource
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	guard let cell = tableView.dequeueReusableCell(withIdentifier: "observationCell") as? ObservationCell else { return UITableViewCell() }
	
		let ob = observationDetail?[indexPath.row]
		cell.observationsCollection = observationDetail?[indexPath.row].observations
		cell.dateLabel.text = String.getStringDateFormat(date: ob?.referenceTime ?? "")
		cell.timeLabel.text = String.getStringTimeFormat(date: ob?.referenceTime ?? "")
		
		let tag = cell.tableViewCellCoordinator.count
		cell.collectionViewCell.tag = tag
		cell.tableViewCellCoordinator[tag] = indexPath
		cell.delegate = self
		if lastIndexPath != indexPath {
				cell.checked = true
		} else {
				cell.checked = false
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return observationDetail?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("tableview didselect \(indexPath.row)")
		lastIndexPath = indexPath
		delegate?.selectedDateItem(at: indexPath.row)
		updateSelectedDate(index: indexPath.row)
		self.tableView.reloadData()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 89
	}
	
	func selectedItemInCollectionView(indexPath: IndexPath) {
		self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: indexPath)
	}
}
