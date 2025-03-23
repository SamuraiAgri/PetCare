// PetCare/Views/EditPetView.swift

import SwiftUI
import PhotosUI

struct EditPetView: View {
    // 環境変数
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    // 元のペットデータ
    private let originalPet: PetModel
    
    // 状態変数
    @State private var name: String
    @State private var type: String
    @State private var breed: String
    @State private var birthday: Date
    @State private var gender: String
    @State private var notes: String
    @State private var selectedImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isSaving = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // ペット種類の選択肢
    private let petTypes = ["dog", "cat", "bird", "fish", "other"]
    private let petTypeNames = ["犬", "猫", "鳥", "魚", "その他"]
    
    // ペット性別の選択肢
    private let genderOptions = ["male", "female"]
    private let genderNames = ["オス", "メス"]
    
    // コールバック関数
    var onComplete: (PetModel?) -> Void
    
    // サービス
    private let petService: PetService
    
    init(pet: PetModel, onComplete: @escaping (PetModel?) -> Void) {
        self.originalPet = pet
        self.onComplete = onComplete
        self.petService = PetService(context: PersistenceController.shared.container.viewContext)
        
        // 初期値の設定
        _name = State(initialValue: pet.name)
        _type = State(initialValue: pet.type)
        _breed = State(initialValue: pet.breed ?? "")
        _birthday = State(initialValue: pet.birthday ?? Date())
        _gender = State(initialValue: pet.gender ?? "male")
        _notes = State(initialValue: pet.notes ?? "")
        
        // 画像データがあれば UIImage に変換
        if let imageData = pet.imageData {
            _selectedImage = State(initialValue: UIImage(data: imageData))
        } else {
            _selectedImage = State(initialValue: nil)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報セクション
                Section(header: Text("基本情報")) {
                    // 名前入力
                    TextField("名前（必須）", text: $name)
                    
                    // ペット種類選択
                    Picker("種類", selection: $type) {
                        ForEach(0..<petTypes.count, id: \.self) { index in
                            Text(petTypeNames[index]).tag(petTypes[index])
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // 品種入力
                    TextField("品種", text: $breed)
                    
                    // 性別選択
                    Picker("性別", selection: $gender) {
                        ForEach(0..<genderOptions.count, id: \.self) { index in
                            Text(genderNames[index]).tag(genderOptions[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // 誕生日選択
                    DatePicker("誕生日", selection: $birthday, in: ...Date(), displayedComponents: .date)
                }
                
                // プロフィール画像セクション
                Section(header: Text("プロフィール画像")) {
                    // 画像表示 / 選択ボタン
                    HStack {
                        Spacer()
                        
                        VStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(radius: 3)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(width: 150, height: 150)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                                Label(selectedImage == nil ? "写真を選択" : "写真を変更", systemImage: "photo")
                                    .font(.subheadline)
                            }
                            .padding(.top, 8)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // メモセクション
                Section(header: Text("メモ")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("ペット情報編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        savePet()
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
            .onChange(of: photoPickerItem) { _ in
                Task {
                    if let data = try? await photoPickerItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            return
                        }
                    }
                    
                    print("画像の読み込みに失敗しました")
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
    
    // ペット情報を保存
    private func savePet() {
        guard !name.isEmpty else {
            alertMessage = "ペットの名前を入力してください"
            showingAlert = true
            return
        }
        
        isSaving = true
        
        // 画像データの取得
        let imageData = selectedImage?.jpegData(compressionQuality: 0.7)
        
        // ペット情報更新
        if let petEntity = petService.fetchPet(byId: originalPet.id) {
            petService.updatePet(
                pet: petEntity,
                name: name,
                type: type,
                breed: breed.isEmpty ? nil : breed,
                birthday: birthday,
                gender: gender,
                weight: originalPet.weight,
                imageData: imageData,
                notes: notes.isEmpty ? nil : notes
            )
            
            // 更新したペットのモデルを作成
            let updatedPet = PetModel(entity: petEntity)
            
            // 完了コールバックを実行
            onComplete(updatedPet)
            
            // 画面を閉じる
            presentationMode.wrappedValue.dismiss()
        } else {
            alertMessage = "ペットデータの更新に失敗しました"
            showingAlert = true
            isSaving = false
        }
    }
}

// MARK: - プレビュー
struct EditPetView_Previews: PreviewProvider {
    static var previews: some View {
        EditPetView(pet: PetModel.sampleData[0]) { _ in }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
