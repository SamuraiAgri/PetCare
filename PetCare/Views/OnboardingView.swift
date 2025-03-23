// PetCare/Views/OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    // 環境オブジェクト
    @EnvironmentObject var appState: AppState
    
    // 状態変数
    @State private var currentPage = 0
    @State private var showAddPetSheet = false
    
    // オンボーディングページデータ
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "pawprint.circle.fill",
            title: "ペットのケアを一元管理",
            description: "PetCare では、あなたの大切なペットの健康管理を簡単に行うことができます。複数のペットを登録して、それぞれの健康状態やスケジュールを管理しましょう。"
        ),
        OnboardingPage(
            image: "heart.text.square.fill",
            title: "健康記録を簡単に",
            description: "体重、体温、症状などの健康情報を記録して、ペットの健康状態を把握。グラフで体重の変化も確認できます。"
        ),
        OnboardingPage(
            image: "calendar.badge.clock",
            title: "スケジュール管理",
            description: "病院の予約やトリミングの予定、給餌スケジュールなどを登録して、うっかり忘れを防止。リマインダーでお知らせします。"
        ),
        OnboardingPage(
            image: "syringe",
            title: "ワクチン接種を管理",
            description: "ワクチンの接種履歴と次回の予定を記録して、期限切れを防止。アプリが有効期限が近づくとお知らせします。"
        ),
        OnboardingPage(
            image: "cube.box.fill",
            title: "ペット用品の在庫管理",
            description: "フードや薬、おもちゃなどの在庫を管理して、必要なときに必要なものを揃えられるように。在庫が少なくなるとアプリがお知らせします。"
        )
    ]
    
    var body: some View {
        ZStack {
            // 背景色
            Color.backgroundColor.ignoresSafeArea()
            
            VStack {
                // ヘッダーエリア（スキップボタン）
                HStack {
                    Spacer()
                    
                    Button("スキップ") {
                        showAddPetSheet = true
                    }
                    .foregroundColor(.primaryColor)
                    .padding()
                }
                
                // タブビュー（ページ切り替え）
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        onboardingPageView(for: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // フッターエリア（次へ/始めるボタン）
                HStack {
                    // 前へボタン（最初のページ以外で表示）
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("前へ")
                            }
                            .padding()
                            .foregroundColor(.primaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    // 次へ/始めるボタン
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            showAddPetSheet = true
                        }
                    }) {
                        HStack {
                            Text(currentPage < pages.count - 1 ? "次へ" : "始める")
                            
                            if currentPage < pages.count - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .frame(minWidth: 120)
                        .padding()
                        .background(Color.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showAddPetSheet) {
            AddPetView { newPet in
                if newPet != nil {
                    // オンボーディング完了
                    appState.completeOnboarding()
                }
            }
        }
    }
    
    // オンボーディングページビューを生成
    private func onboardingPageView(for page: OnboardingPage) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            // アイコン
            Image(systemName: page.image)
                .font(.system(size: 100))
                .foregroundColor(.primaryColor)
            
            // タイトル
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 説明文
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// オンボーディングページのデータ構造
struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}

// MARK: - プレビュー
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppState())
    }
}
