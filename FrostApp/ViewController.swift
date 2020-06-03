//
//  ViewController.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/29/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet var tableView: UITableView!
	var listOfStations = [StationsDetail]() {
		didSet {
			DispatchQueue.main.async {
				self.tableView.reloadData()
				self.dismissHUDWithNavigation(isAnimated: true)
			}
		}
	}
	var network = NetworkManager()
	var listOfObservations: ObservationsResponse?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.showHUDWithNavigation(progressLabel: "Loading...")
		network.getStations { [weak self] result in
			switch result {
			case .failure(let error):
				print("check ekekekek")
				print(error)
			case .success(let stations):
				self?.listOfStations = stations.filter { $0.externalIds?.isEmpty != nil }
			}
		}
	}
	
	// MARK: UITableView DataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return listOfStations.count
	}

	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath) as! StationCell
		let station = listOfStations[indexPath.row]
		cell.stationLabel.text = station.shortName
		cell.locationNameLabel.text = station.municipality
		cell.countryLabel.text = station.country
		return cell
	}
	
	// MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 169
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		gettingObservationRequest(indexPath: indexPath)
	}
	
	// MARK: - Helper Methods
	
	fileprivate func gettingObservationRequest(indexPath: IndexPath) {
		self.showHUDWithNavigation(progressLabel: "Loading...")
		network.getObservations(stationID: "SN18700", dateRangeFormat: "R14/2020-05-27/2020-05-27/PT01H") { (res) in
			switch res {
			case .failure(let error):
				DispatchQueue.main.async {
					self.dismissHUDWithNavigation(isAnimated: true)
					self.alert(message: error.localizedDescription)
				}
			case .success(let observation):
				self.listOfObservations = observation
				DispatchQueue.main.async {
					self.dismissHUDWithNavigation(isAnimated: true)
					self.performSegue(withIdentifier: "toWeatherScreen", sender: indexPath)
				}
			}
		}
	}
	
	// MARK: Segue

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toWeatherScreen" {
				let vc = segue.destination as? WeatherViewController
				let indexPath = sender as! IndexPath
				vc?.stationDetail = listOfStations[indexPath.row]
				vc?.observationDetail = listOfObservations
			}
	}
}

