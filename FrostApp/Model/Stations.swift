//
//  Stations.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/29/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import Foundation

struct StationsResponse: Codable {
	var data: [StationsDetail]
}

struct StationsDetail: Codable {
	var id: String?
	var name: String?
	var shortName: String?
	var geometry: StationGeometry?
	var municipality: String?
	var externalIds: [String]?
	var country: String?
	
	private enum StationsDetailCodingKeys: String, CodingKey {
				case id
				case name
				case shortName
				case geometry
				case municipality
				case externalIds
				case country
		}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: StationsDetailCodingKeys.self)
		id = try container.decodeIfPresent(String.self, forKey: .id)
		name = try container.decodeIfPresent(String.self, forKey: .name)
		shortName = try container.decodeIfPresent(String.self, forKey: .shortName)
		geometry = try container.decodeIfPresent(StationGeometry.self, forKey: .geometry)
		municipality = try container.decodeIfPresent(String.self, forKey: .municipality)
		externalIds = try container.decodeIfPresent([String].self, forKey: .externalIds)
		country = try container.decodeIfPresent(String.self, forKey: .country)
	}
}

struct StationGeometry: Codable {
	var type: String?
	var coordinates: [Double]?
	var nearest: Bool?
	
	private enum StationGeometryCodingKeys: String, CodingKey {
				case type = "@type"
				case coordinates
				case nearest
		}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: StationGeometryCodingKeys.self)
		type = try container.decodeIfPresent(String.self, forKey: .type)
		coordinates = try container.decodeIfPresent([Double].self, forKey: .coordinates)
		nearest = try container.decodeIfPresent(Bool.self, forKey: .nearest)
	}
}
