//
//  EstatisticasModel.swift
//  DeepFinance
//
//  Created by Marcelo Jesus on 29/07/25.
//
import Foundation
import SwiftUI



struct StatisticModel: Identifiable {
    let id = UUID().uuidString
    let title: String
    let value: String
    let percentageChange: Double?
}
