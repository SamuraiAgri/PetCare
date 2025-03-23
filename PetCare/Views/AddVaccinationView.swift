// PetCare/Views/AddVaccinationView.swift

import SwiftUI

struct AddVaccinationView: View {
    // 環境変数
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    // ペットデータ
    private let pet: PetModel
    
    // 状態変数
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var hasExpiryDate: Bool = true
    @State private var expiryDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var vetName: String = ""
    @State private var clinicName: String = ""
    @State private var hasNextDueDate: Bool = false
    @State private var nextDueDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var notes: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    
    // よく使うワクチン名の候補
    private let commonVaccineNames = [
        "混合ワクチン（5種）",
        "混合ワクチン（7種）",
        "混合ワクチン（9種）",
        "狂犬病ワクチン",
        "ボルデテラ菌",
        "レプトスピラ",
        "フィラリア予防",
        "ノミ・マダニ予防"
    ]
    
    // コールバック関数
    var onComplete: (VaccinationModel?) -> Void
    
    // ビューモデル
    private let viewModel: PetDetailViewModel
    
    init(pet: PetModel, onComplete: @escaping (VaccinationModel?) -> Void) {
        self.pet = pet
        self.onComplete = onComplete
        self.viewModel = PetDetailViewModel(pet: pet)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報セクション
                Section(header: Text("基本情報")) {
                    // ペット名表示
                    HStack {
                        Text("ペット名")
                        Spacer()
                        Text(pet.name)
                            .foregroundColor(.secondaryTextColor)
                    }
                    
                    // ワクチン名入力
                    TextField("ワクチン名（必須）", text: $name)
                    
                    // よく使うワクチン選択
                    if name.isEmpty {
                        Section(header: Text("よく使うワクチン")) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(commonVaccineNames, id: \.self) { vaccineName in
                                        Button(action: {
                                            name = vaccineName
                                        }) {
                                            Text(vaccineName)
                                                .font(.caption)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.primaryColor.opacity(0.1))
                                                .foregroundColor(.primaryColor)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 接種日選択
                    DatePicker("接種日", selection: $date, in: ...Date(), displayedComponents: .date)
                }
                
                // 有効期限セクション
                Section(header: Text("有効期限")) {
                    Toggle("有効期限を設定", isOn: $hasExpiryDate)
                    
                    if hasExpiryDate {
                        DatePicker("有効期限", selection: $expiryDate, in: date..., displayedComponents: .date)
                    }
                }
                
                // 次回接種予定セクション
                Section(header: Text("次回接種予定")) {
                    Toggle("次回接種日を設定", isOn: $hasNextDueDate)
                    
                    if hasNextDueDate {
                        DatePicker("次回接種予定日", selection: $nextDueDate, in: date..., displayedComponents: .date)
                    }
                }
                
                // 接種場所セクション
                Section(header: Text("接種場所（任意）")) {
                    TextField("動物病院名", text: $clinicName)
                    TextField("獣医師名", text: $vetName)
                }
                
                // メモセクション
                Section(header: Text("メモ（任意）")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("ワクチン記録追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveVaccination()
                    }
                    .disabled(name.isEmpty || isSaving)
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
    
    // ワクチン記録を保存
    private func saveVaccination() {
        guard !name.isEmpty else {
            alertMessage = "ワクチン名を入力してください"
            showingAlert = true
            return
        }
        
        isSaving = true
        
        // 次回接種日があるかどうかで条件分岐
        let nextDueDateValue = hasNextDueDate ? nextDueDate : nil
        
        // 有効期限があるかどうかで条件分岐
        let expiryDateValue = hasExpiryDate ? expiryDate : nil
        
        // ワクチン記録を追加
        viewModel.addVaccination(
            name: name,
            date: date,
            expiryDate: expiryDateValue,
            vetName: vetName.isEmpty ? nil : vetName,
            clinicName: clinicName.isEmpty ? nil : clinicName,
            notes: notes.isEmpty ? nil : notes,
            nextDueDate: nextDueDateValue
        )
        
        // 完了コールバックを実行（詳細情報は必要ないためnil）
        onComplete(nil)
        
        // 画面を閉じる
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - プレビュー
struct AddVaccinationView_Previews: PreviewProvider {
    static var previews: some View {
        AddVaccinationView(pet: PetModel.sampleData[0]) { _ in }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
