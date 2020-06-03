//
//  NetworkManager.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/29/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import Foundation


struct NetworkManager {
	
	private let clientID = "9e0e4f43-d6da-4572-8dd9-f6bad9d545c0"
	private let stationsURL = "https://frost.met.no/sources/v0.jsonld?types=SensorSystem&country=no&municipality=halden&fields=id,name,shortname,municipality,geometry,externalIds,country"
	private let observationsURL =  "https://frost.met.no/observations/v0.jsonld?sources="

	fileprivate func setupURLRequestNetwork(urlString: String) -> NSMutableURLRequest {
			var urlRequest = NSMutableURLRequest()
			if let clientData = clientID.data(using: String.Encoding.utf8) {
				let base64ClientString = clientData.base64EncodedString()
				if let url = URL(string: urlString)  {
					 urlRequest = NSMutableURLRequest(url: url,
																						cachePolicy: .useProtocolCachePolicy,
																						timeoutInterval: 10.0)
					urlRequest.httpMethod = "GET"
					urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
					urlRequest.setValue("Basic \(base64ClientString)", forHTTPHeaderField: "Authorization")
				}
			}
			return urlRequest
		}
	
	
	func getStations (completion : @escaping(Result<[StationsDetail], FrostAppErrorHandling>) -> ()) {
		let dataTask = URLSession.shared.dataTask(with: setupURLRequestNetwork(urlString: stationsURL) as URLRequest) { (data, res, _) in
			guard let jsonData = data else {
				completion(.failure(.noDataAvailable))
				return
			}
			do {
				let decoder = JSONDecoder()
				let stationsResponse = try decoder.decode(StationsResponse.self, from: jsonData)
				let stationsDetail = stationsResponse.data
				completion(.success(stationsDetail))
			} catch {
					if let response = res as? HTTPURLResponse {
					completion(.failure(self.handleNetworkErrorResponse(response)))
				} else {
					completion(.failure(.failure))
				}
			}
		}
		dataTask.resume()
	}
	
	func getObservations (stationID: String, dateRangeFormat: String, completion : @escaping(Result<ObservationsResponse, FrostAppErrorHandling>) -> ()) {
		let urlString = observationsURL + stationID + "&referencetime=" + dateRangeFormat + "&elements=wind_speed,air_temperature,boolean_fair_weather(cloud_area_fraction%20P1D)&fields=elementId,unit,referenceTime,level,value"
		let dataTask = URLSession.shared.dataTask(with: setupURLRequestNetwork(urlString: urlString) as URLRequest) { (data, res, _) in
			guard let jsonData = data else {
				completion(.failure(.noDataAvailable))
				return
			}
			do {
				let decoder = JSONDecoder()
				let observationsResponse = try decoder.decode(ObservationsResponse.self, from: jsonData)
				let observationDetail = observationsResponse
				completion(.success(observationDetail))
			} catch {
				if let response = res as? HTTPURLResponse {
					print("chejejej \(response.statusCode)")
					completion(.failure(self.handleNetworkErrorResponse(response)))
				} else {
					completion(.failure(.failure))
				}
			}
		}
		dataTask.resume()
	}
	
	fileprivate func handleNetworkErrorResponse(_ response: HTTPURLResponse) -> FrostAppErrorHandling {
		switch response.statusCode {
		case 400: return .invalidParameters
		case 404: return .noDataAvailable
		case 412: return .noTimeSeriesAvailable
		case 429: return .serviceIsBusy
		case 500: return .internalError
		default: return .failure
		}
	}
}

	// API Error Response based on the link https://frost.met.no/api.html#!/observations/observations

enum FrostAppErrorHandling: Error {
	case noDataAvailable
	case invalidParameters
	case noTimeSeriesAvailable
	case serviceIsBusy
	case internalError
	case failure
}

extension FrostAppErrorHandling: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .invalidParameters: return "Invalid parameter value or malformed request."
		case .noTimeSeriesAvailable: return "No available time series"
		case .serviceIsBusy: return "The service is busy. Too many requests in progress. Retry-After is set with the number of seconds before the request should be retried again.."
		case .internalError: return "Internal server error"
		case .failure: return "Cannot process data."
		case .noDataAvailable:  return "No data was found for the query parameters."
		}
	}
}
