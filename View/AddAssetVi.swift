//
//  AddAssetVi.swift
//  DeepFinance
//
//  Created by Marcelo Jesus on 29/07/25.
//

import SwiftUI



struct AddAssetView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedCoin: Coin? = nil
    @State private var quantityText: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $vm.searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            ForEach(vm.allCoins) { coin in
                                CoinLogoView(coin: coin)
                                    .frame(width: 75)
                                    .padding(4)
                                    .onTapGesture {
                                        withAnimation(.easeIn) {
                                            selectedCoin = coin
                                        }
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedCoin?.id == coin.id ? Color.theme.green : Color.clear, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.leading)
                    }

                    if let coin = selectedCoin {
                        VStack(spacing: 20) {
                            HStack {
                                Text("Preço atual de \(coin.symbol.uppercased()):")
                                Spacer()
                                Text(coin.currentPrice.asCurrencyWith6Decimals())
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Quantidade:")
                                Spacer()
                                TextField("Ex: 1.4", text: $quantityText)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Valor total:")
                                Spacer()
                                Text(getCurrentValue().asCurrencyWith2Decimals())
                            }
                        }
                        .animation(.none, value: selectedCoin)
                        .padding()
                        .font(.headline)
                    }
                }
            }
            .navigationTitle("Adicionar Ativo")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveButtonPressed()
                    }, label: {
                        Text("Salvar".uppercased())
                    })
                    .opacity(selectedCoin != nil && Double(quantityText.replacingOccurrences(of: ",", with: ".")) != nil ? 1.0 : 0.0)
                }
            }
        }
    }
    
    private func getCurrentValue() -> Double {
        if let quantity = Double(quantityText.replacingOccurrences(of: ",", with: ".")) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
    
    private func saveButtonPressed() {
        guard
            let coin = selectedCoin,
            let amount = Double(quantityText.replacingOccurrences(of: ",", with: "."))
        else { return }
        
        // Salva no portfólio
        vm.updatePortfolio(coin: coin, amount: amount)
        
        // Fecha a tela
        presentationMode.wrappedValue.dismiss()
    }
}
