//
//  NetworkService.swift
//  CryptoPriceOnline
//
//  Created by Кирилл Заборский on 22.09.2020.
//

import Foundation
import Combine

final class NetworkService {
    var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.coinranking.com"
        components.path = "/v1/public/coins"
        components.queryItems = [URLQueryItem(name: "base", value: "USD"), URLQueryItem(name: "timePeriod", value: "24h")]
        return components
    }
    
    func fetchCoins() -> AnyPublisher<NetworkDataContainer, Error> {
        return URLSession.shared.dataTaskPublisher(for: components.url!)
            .map { $0.data }
            .decode(type: NetworkDataContainer.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct NetworkDataContainer: Decodable {
    let status: String
    let data: Data
}

struct Data: Decodable {
    var coins: [Coin]
}

struct Coin: Decodable, Hashable {
    let id: Int
        let uuid, slug, symbol, name: String
        let coinDescription, color: String?
        let iconUrl: String
        let websiteUrl: String?
        let confirmedSupply: Bool
        let numberOfMarkets, numberOfExchanges: Int
        let volume, marketCap: Int
        let price: String
        let circulatingSupply, totalSupply: Double
        let approvedSupply: Bool
        let firstSeen, listedAt: Int
        let change: Double
        let rank: Int
        let history: [String]
        let penalty: Bool
}

