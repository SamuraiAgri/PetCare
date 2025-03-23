// PetCare/Views/MainTabView.swift

import SwiftUI

struct MainTabView: View {
    // タブの選択状態
    @State private var selectedTab = 0
    
    // 環境オブジェクト
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // ホーム画面
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("ホーム", systemImage: "house.fill")
            }
            .tag(0)
            
            // ペット一覧画面
            NavigationView {
                PetListView()
            }
            .tabItem {
                Label("ペット", systemImage: "pawprint.fill")
            }
            .tag(1)
            
            // カレンダー画面
            NavigationView {
                CalendarView()
            }
            .tabItem {
                Label("スケジュール", systemImage: "calendar")
            }
            .tag(2)
            
            // 用品在庫管理画面
            NavigationView {
                SuppliesView()
            }
            .tabItem {
                Label("用品", systemImage: "cube.box.fill")
            }
            .tag(3)
            
            // ガイド・設定画面
            NavigationView {
                GuideView()
            }
            .tabItem {
                Label("ガイド", systemImage: "book.fill")
            }
            .tag(4)
        }
        .accentColor(.primaryColor)
    }
}

// MARK: - プレビュー
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppState())
    }
}
