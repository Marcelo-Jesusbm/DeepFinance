//
//  ViewModel.swift
//  DeepFinance
//
//  Created by Marcelo Jesus on 29/07/25.
//

import Combine
import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var statistics: [StatisticModel] = []
    @Published var allCoins: [Coin] = []
    @Published var portfolioCoins: [Coin] = []
    @Published var searchText: String = ""

    private let coinDataService = CoinDataService()
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        addSubscribers()
    }

    func addSubscribers() {
        // Observa mudanças no texto de busca e nos dados das moedas
        $searchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .assign(to: \.allCoins, on: self)
            .store(in: &cancellables)
        
        // Observa mudanças no portfólio (Core Data) e atualiza a lista de moedas do portfólio
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapPortfolioCoins)
            .assign(to: \.portfolioCoins, on: self)
            .store(in: &cancellables)

        // Calcula as estatísticas do portfólio sempre que ele é atualizado
        $portfolioCoins
            .map(mapPortfolioStatistics)
            .assign(to: \.statistics, on: self)
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: Coin, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    private func filterCoins(text: String, coins: [Coin]) -> [Coin] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        return coins.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) ||
                   coin.symbol.lowercased().contains(lowercasedText)
        }
    }
    
    private func mapPortfolioCoins(allCoins: [Coin], portfolioEntities: [PortfolioEntity]) -> [Coin] {
        allCoins
            .compactMap { (coin) -> Coin? in
                guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else {
                    return nil
                }
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    
    private func mapPortfolioStatistics(portfolioCoins: [Coin]) -> [StatisticModel] {
        let portfolioValue = portfolioCoins.map(\.currentHoldingsValue).reduce(0, +)
        
        let previousValue = portfolioCoins.map { (coin) -> Double in
            let currentValue = coin.currentHoldingsValue
            let percentChange = (coin.priceChangePercentage24h ?? 0) / 100
            return currentValue / (1 + percentChange)
        }.reduce(0, +)

        let percentageChange = ((portfolioValue - previousValue) / previousValue)
        
        let stat1 = StatisticModel(title: "Valor do Portfólio", value: portfolioValue.asCurrencyWith2Decimals(), percentageChange: percentageChange)
        // ... outras estatísticas poderiam ser adicionadas aqui
        
        return [stat1]
    }
}
