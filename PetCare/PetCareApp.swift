// PetCare/PetCareApp.swift

import SwiftUI

@main
struct PetCareApp: App {
    // CoreData 永続コントローラの共有インスタンス
    let persistenceController = PersistenceController.shared
    
    // アプリ起動時の状態管理
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
        }
    }
}

// アプリ全体の状態管理
class AppState: ObservableObject {
    // オンボーディング完了状態
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    // 選択中のペットID（ペット選択を画面間で共有）
    @Published var selectedPetId: UUID? {
        didSet {
            if let petId = selectedPetId {
                UserDefaults.standard.set(petId.uuidString, forKey: "selectedPetId")
            } else {
                UserDefaults.standard.removeObject(forKey: "selectedPetId")
            }
        }
    }
    
    init() {
        // 保存されたオンボーディング状態を読み込み
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // 保存されたペットIDを読み込み
        if let petIdString = UserDefaults.standard.string(forKey: "selectedPetId"),
           let petId = UUID(uuidString: petIdString) {
            self.selectedPetId = petId
        } else {
            self.selectedPetId = nil
        }
    }
    
    // オンボーディングを完了
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    // ペットを選択
    func selectPet(_ petId: UUID?) {
        selectedPetId = petId
    }
}
