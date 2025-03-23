// PetCare/ContentView.swift

import SwiftUI
import CoreData

struct ContentView: View {
    // 環境変数
    @Environment(\.managedObjectContext) private var viewContext
    
    // 環境オブジェクト
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppState())
    }
}
