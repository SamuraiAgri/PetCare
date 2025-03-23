// PetCare/Views/AppointmentEntryView.swift

import SwiftUI
import CoreData

struct AppointmentEntryView: View {
    // 環境変数
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    // 環境オブジェクト
    @EnvironmentObject var appState: AppState
    
    // ペットデータ（任意）
    private let pet: PetModel?
    
    // 状態変数
    @State private var title: String = ""
    @State private var type: String = "vet"
    @State private var date: Date
    @State private var time: Date
    @State private var duration: String = "60"
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var reminderTime: String = "60"
    @State private var isDone: Bool = false
    @State private var selectedPetId: UUID?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    @State private var pets: [PetModel] = []
    
    // 予約タイプの選択肢
    private let appointmentTypes = ["vet", "grooming", "other"]
    private let appointmentTypeNames = ["獣医", "トリミング", "その他"]
    
    // リマインダー時間の選択肢
    private let reminderTimeOptions = ["0", "15", "30", "60", "120", "1440"]
    private let reminderTimeNames = ["設定なし", "15分前", "30分前", "1時間前", "2時間前", "1日前"]
    
    // 所要時間の選択肢
    private let durationOptions = ["0", "30", "60", "90", "120", "180"]
    private let durationNames = ["設定なし", "30分", "1時間", "1時間30分", "2時間", "3時間"]
    
    // コールバック関数
    var onComplete: (AppointmentModel?) -> Void
    
    // 初期化
    init(date: Date? = nil, pet: PetModel? = nil, onComplete: @escaping (AppointmentModel?) -> Void) {
        self.pet = pet
        self.onComplete = onComplete
        
        if let date = date {
            _date = State(initialValue: date)
        } else {
            _date = State(initialValue: Date())
        }
        
        // 現在の時間を30分単位で丸める
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let roundedMinute = ((minute + 30) / 30) * 30 % 60
        let adjustedHour = hour + ((minute + 30) / 60)
        
        if let roundedTime = calendar.date(bySettingHour: adjustedHour, minute: roundedMinute, second: 0, of: Date()) {
            _time = State(initialValue: roundedTime)
        } else {
            _time = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報セクション
                Section(header: Text("基本情報")) {
                    TextField("タイトル（例: 定期健診）", text: $title)
                    
                    // ペット選択
                    if let pet = pet {
                        HStack {
                            Text("ペット")
                            Spacer()
                            Text(pet.name)
                                .foregroundColor(.secondaryTextColor)
                        }
                    } else if !pets.isEmpty {
                        Picker("ペット", selection: $selectedPetId) {
                            Text("選択してください").tag(nil as UUID?)
                            ForEach(pets) { pet in
                                Text(pet.name).tag(pet.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // 予約タイプ選択
                    Picker("タイプ", selection: $type) {
                        ForEach(0..<appointmentTypes.count, id: \.self) { index in
                            Text(appointmentTypeNames[index]).tag(appointmentTypes[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // 日付選択
                    DatePicker("日付", selection: $date, displayedComponents: .date)
                    
                    // 時間選択
                    DatePicker("時間", selection: $time, displayedComponents: .hourAndMinute)
                    
                    // 所要時間選択
                    Picker("所要時間", selection: $duration) {
                        ForEach(0..<durationOptions.count, id: \.self) { index in
                            Text(durationNames[index]).tag(durationOptions[index])
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // 場所入力
                    TextField("場所（例: ○○動物病院）", text: $location)
                }
                
                // リマインダーセクション
                Section(header: Text("リマインダー")) {
                    Picker("通知時間", selection: $reminderTime) {
                        ForEach(0..<reminderTimeOptions.count, id: \.self) { index in
                            Text(reminderTimeNames[index]).tag(reminderTimeOptions[index])
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // メモセクション
                Section(header: Text("メモ（任意）")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("予定の追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveAppointment()
                    }
                    .disabled(title.isEmpty || isSaving)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("エラー"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                loadPets()
                
                // 特定のペットが指定されている場合は選択状態にする
                if let pet = pet {
                    selectedPetId = pet.id
                }
                // 選択中のペットがあれば設定
                else if let selectedPetId = appState.selectedPetId {
                    self.selectedPetId = selectedPetId
                }
            }
        }
    }
    
    // ペットデータを読み込み
    private func loadPets() {
        do {
            let request: NSFetchRequest<Pet> = Pet.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
            
            let results = try viewContext.fetch(request)
            self.pets = results.map { PetModel(entity: $0) }
        } catch {
            print("ペットデータの取得エラー: \(error)")
        }
    }
    
    // アポイントメントを保存
    private func saveAppointment() {
        guard !title.isEmpty else {
            alertMessage = "タイトルを入力してください"
            showingAlert = true
            return
        }
        
        isSaving = true
        
        do {
            // CoreData エンティティの作成
            let appointment = Appointment(context: viewContext)
            appointment.id = UUID()
            appointment.title = title
            appointment.type = type
            appointment.date = date
            appointment.time = time // Date型として直接保存
            appointment.duration = Int32(duration) ?? 0
            appointment.location = location.isEmpty ? nil : location
            appointment.notes = notes.isEmpty ? nil : notes
            appointment.isDone = isDone
            appointment.reminderTime = Int32(reminderTime) ?? 0
            appointment.createdAt = Date()
            appointment.updatedAt = Date()
            
            // ペットの関連付け
            if let petId = selectedPetId ?? pet?.id {
                let petRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
                petRequest.predicate = NSPredicate(format: "id == %@", petId as CVarArg)
                petRequest.fetchLimit = 1
                
                if let pet = try viewContext.fetch(petRequest).first {
                    appointment.pet = pet
                }
            }
            
            // 保存
            try viewContext.save()
            
            // 完了コールバックを実行
            let appointmentModel = AppointmentModel(entity: appointment)
            onComplete(appointmentModel)
            
            // 画面を閉じる
            presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = "保存中にエラーが発生しました: \(error.localizedDescription)"
            showingAlert = true
            isSaving = false
        }
    }
}

// MARK: - プレビュー
struct AppointmentEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentEntryView { _ in }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppState())
    }
}
