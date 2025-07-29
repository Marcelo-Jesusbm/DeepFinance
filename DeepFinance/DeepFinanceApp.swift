//
//  DeepFinanceApp.swift
//  DeepFinance
//
//  Created by Marcelo Jesus on 29/07/25.
//

import SwiftUI
import Combine
import CoreData


@main
struct FinanceDashboardApp: App {
    // Gerenciador de Core Data (Corrigido: removido @StateObject)
    private let persistenceController = PersistenceController.shared
    // ViewModel principal, compartilhado por toda a aplicação
    @StateObject private var vm = HomeViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true) // Usamos uma barra de navegação customizada
            }
            // Injeta o contexto do Core Data no ambiente do SwiftUI
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            // Fornece o ViewModel para as views filhas através do ambiente
            .environmentObject(vm)
        }
    }
}
