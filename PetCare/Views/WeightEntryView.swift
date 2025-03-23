// PetCare/Views/WeightEntryView.swift

import SwiftUI

struct WeightEntryView: View {
    // 環境変数
    @Environment(\.presentationMode) private var presentationMode
    
    // ペットデータ
    private let pet: PetModel
    
    // 状態変数
    @State private var weightText: String = ""
    @State private var date: Date = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // コールバック関数
    var onComplete: (Double?) -> Void
    
    init(pet: PetModel, onComplete: @escaping (Double?) -> Void) {
        self.pet = pet
        self.onComplete = onComplete
        
        // 現在の体重があれば初期値として設定
        if let weight = pet.weight {
            _weightText = State(initialValue: String(format: "%.1f", weight))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("体重を記録")) {
                    // ペット名表示
                    HStack {
                        Text("ペット名")
                        Spacer()
                        Text(pet.name)
                            .foregroundColor(.secondaryTextColor)
                    }
                    
                    // 体重入力
                    HStack {
                        Text("体重")
                        TextField("例: 5.2", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                            .foregroundColor(.secondaryTextColor)
                    }
                    
                    // 日付選択
                    DatePicker("日付", selection: $date, in: ...Date(), displayedComponents: .date)
                }
                
                Section(header: Text("過去の記録"), footer: Text("体重の履歴は「健康記録」タブで確認できます。")) {
                    // 過去の体重記録表示（最新3件）
                    if let weight = pet.weight {
                        HStack {
                            Text("現在の体重")
                            Spacer()
                            Text(String(format: "%.1f kg", weight))
                                .foregroundColor(.primaryTextColor)
                        }
                    }
                }
            }
            .navigationTitle("体重記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveWeight()
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("エラー"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // 体重を保存
    private func saveWeight() {
        // 入力チェック
        guard !weightText.isEmpty else {
            alertMessage = "体重を入力してください"
            showingAlert = true
            return
        }
        
        // 数値変換
        guard let weight = Double(weightText.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "正しい体重を入力してください"
            showingAlert = true
            return
        }
        
        // コールバックを実行
        onComplete(weight)
        
        // 画面を閉じる
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - プレビュー
struct WeightEntryView_Previews: PreviewProvider {
    static var previews: some View {
        WeightEntryView(pet: PetModel.sampleData[0]) { _ in }
    }
}
