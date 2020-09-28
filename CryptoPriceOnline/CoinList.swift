//
//  ContentView.swift
//  CryptoPriceOnline
//
//  Created by Кирилл Заборский on 22.09.2020.
//

import SwiftUI
import Combine
import SwiftUICharts

struct CoinList: View {
    
    @ObservedObject private var viewModel = CoinListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.coinViewModels, id: \.self) { coinViewModel in
                HStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8.0) {
                            Text(coinViewModel.symbol)
                                .font(.title)
                            Text(coinViewModel.name)
                                .font(.headline)
                                .fontWeight(.light)
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            Text(coinViewModel.formattedPrice)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        HStack {
                            if coinViewModel.change > 0 {
                                Image(systemName:"arrow.up")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.green)
                            } else if coinViewModel.change < 0 {
                                Image(systemName:"arrow.down")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName:"􀄬")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                            Text("\(coinViewModel.change, specifier: "%.2f") %")
                                .fontWeight(.light)
                        }
                        .frame(width: 85.0)
                    }.padding(.top)
                }
                
            }.onAppear {
                viewModel.fetchCoins()
                
            }.navigationTitle("Coins")
        }
    }
}

struct CoinList_Previews: PreviewProvider {
    static var previews: some View {
        CoinList()
    }
}

class CoinListViewModel:ObservableObject {
    
    private let networkManager = NetworkService()
    
    @Published var coinViewModels = [CoinViewModel]()
    
    var cancellabel: AnyCancellable?
    
    func fetchCoins() {
        cancellabel = networkManager.fetchCoins().sink(receiveCompletion: { _ in
            
        }, receiveValue: { dataContainer in
            self.coinViewModels = dataContainer.data.coins.map { CoinViewModel($0) }
            print(self.coinViewModels)
        })
    }
}

struct CoinViewModel: Hashable {
    private let coin: Coin
    
    var name: String {
        return coin.name
    }
    
    var formattedPrice: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        guard let price = Double(coin.price), let formattedPrice = numberFormatter.string(from: NSNumber(value: price)) else { return "" }
        
        return formattedPrice
    }
    
    var change: Double {
        return coin.change
    }
    
    var symbol: String {
        return coin.symbol
    }
    
    var history: [String] {
        return coin.history
    }
    
    init(_ coin: Coin) {
        self.coin = coin
    }
}
