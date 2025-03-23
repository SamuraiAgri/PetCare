// PetCare/Views/AddHealthRecordView.swift

import SwiftUI

struct AddHealthRecordView: View {
    // 環境変数
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    // ペットデータ
    private let pet: PetModel
    
    // 状態変数
    @State private var date: Date = Date()
    @State private var weightText: String = ""
    @State private var temperatureText: String = ""
    @State private var symptoms: String = ""
    @State private var medications: String = ""
    @State private var notes: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    
    // コールバック関数
    var onComplete: (HealthRecordModel?) -> Void
    
    // サービス
    private let healthRecordService: HealthRecordService
    private let petService: PetService
    
    init(pet: PetModel, onComplete: @escaping (HealthRecordModel?) -> Void) {
        self.pet = pet
        self.onComplete = onComplete
        self.healthRecordService = HealthRecordService(context: PersistenceController.shared.container.viewContext)
        self.petService = PetService(context: PersistenceController.shared.container.viewContext)
        
        // ペットの現在の体重があれば初期値として設定
        if let weight = pet.weight {
            _weightText = State(initialValue: String(format: "%.1f", weight))
        }
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
                    
                    // 日付選択
                    DatePicker("日付", selection: $date, in: ...Date(), displayedComponents: .date)
                    
                    // 体重入力（任意）
                    HStack {
                        Text("体重（任意）")
                        TextField("例: 5.2", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                            .foregroundColor(.secondaryTextColor)
                    }
                    
                    // 体温入力（任意）
                    HStack {
                        Text("体温（任意）")
                        TextField("例: 38.5", text: $temperatureText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("°C")
                            .foregroundColor(.secondaryTextColor)
                    }
                }
                
                // 症状セクション
                Section(header: Text("症状（任意）")) {
                    TextEditor(text: $symptoms)
                        .frame(minHeight: 80)
                }
                
                // 投薬セクション
                Section(header: Text("投薬（任意）")) {
                    TextEditor(text: $medications)
                        .frame(minHeight: 80)
                }
                
                // メモセクション
                Section(header: Text("メモ（任意）")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("健康記録追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveHealthRecord()
                    }
                    .disabled(isSaving)
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
    
    // 健康記録を保存
    private func saveHealthRecord() {
        isSaving = true
        
        // 体重の数値変換（任意項目）
        let weight: Double? = {
            if weightText.isEmpty {
                return nil
            }
            return Double(weightText.replacingOccurrences(of: ",", with: "."))
        }()
        
        // 体温の数値変換（任意項目）
        let temperature: Double? = {
            if temperatureText.isEmpty {
                return nil
            }
            return Double(temperatureText.replacingOccurrences(of: ",", with: "."))
        }()
        
        // CoreData エンティティ取得
        if let petEntity = petService.fetchPet(byId: pet.id) {
            // 健康記録作成
            let healthRecord = healthRecordService.createHealthRecord(
                pet: petEntity,
                date: date,
                weight: weight,
                temperature: temperature,
                symptoms: symptoms.isEmpty ? nil : symptoms,
                medications: medications.isEmpty ? nil : medications,
                notes: notes.isEmpty ? nil : notes
            )
            
            // 作成した健康記録のモデルを作成
            let healthRecordModel = HealthRecordModel(entity: healthRecord)
            
            // 完了コールバックを実行
            onComplete(healthRecordModel)
            
            // 画面を閉じる
            presentationMode.wrappedValue.dismiss()
        } else {
            alertMessage = "ペットデータの取得に失敗しました"
            showingAlert = true
            isSaving = false
        }
    }
}

// MARK: - プレビュー
struct AddHealthRecordView_Previews: PreviewProvider {
    static var previews: some View {
        AddHealthRecordView(pet: PetModel.sampleData[0]) { _ in }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
