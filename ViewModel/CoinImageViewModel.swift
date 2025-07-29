//
//  CoinImageViewModel.swift
//  DeepFinance
//
//  Created by Marcelo Jesus on 29/07/25.
//

import Combine
import SwiftUI
import Foundation



class CoinImageViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    
    private let coin: Coin
    private let dataService: CoinImageService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: Coin) {
        self.coin = coin
        self.dataService = CoinImageService(coin: coin)
        self.addSubscribers()
        self.isLoading = true
    }
    
    private func addSubscribers() {
        dataService.$image
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            }, receiveValue: { [weak self] (returnedImage) in
                self?.image = returnedImage
            })
            .store(in: &cancellables)
    }
}
