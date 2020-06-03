//
//  Observations.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/29/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import Foundation


struct ObservationsResponse: Codable {
	var data: [ObservationsDetails]
}

struct ObservationsDetails: Codable {
	var referenceTime: String?
	var observations: [ObservationsChildDetails]?
	
	private enum ObservationsDetailsCodingKeys: String, CodingKey {
				case referenceTime
				case observations
		}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: ObservationsDetailsCodingKeys.self)
		referenceTime = try container.decodeIfPresent(String.self, forKey: .referenceTime)
		observations = try container.decodeIfPresent([ObservationsChildDetails].self, forKey: .observations)
	}
	
}

struct ObservationsChildDetails: Codable {
	var elementId: String?
	var value: Double?
	var level: ObservationsLevel?
	
	
	private enum ObservationsChildDetailsCodingKeys: String, CodingKey {
				case elementId
				case value
				case level
		}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: ObservationsChildDetailsCodingKeys.self)
		elementId = try container.decodeIfPresent(String.self, forKey: .elementId)
		value = try container.decodeIfPresent(Double.self, forKey: .value)
		level = try container.decodeIfPresent(ObservationsLevel.self, forKey: .level)
	}
	
}
struct ObservationsLevel: Codable {
	var levelType: String?
	var value: Double?
	
	private enum ObservationsLevelCodingKeys: String, CodingKey {
				case levelType
				case value
		}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: ObservationsLevelCodingKeys.self)
		levelType = try container.decodeIfPresent(String.self, forKey: .levelType)
		value = try container.decodeIfPresent(Double.self, forKey: .value)
	}
}
