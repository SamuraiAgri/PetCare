// PetCare/Views/AddPetView.swift

import SwiftUI
import PhotosUI

struct AddPetView: View {
    // 環境変数
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    // 状態変数
    @State private var name: String = ""
    @State private var type: String = "dog"
    @State private var breed: String = ""
    @State private var birthday: Date = Date()
    @State private var gender: String = "male"
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isShowingPhotoPicker = false
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
    
    init(onComplete: @escaping (PetModel?) -> Void) {
        self.onComplete = onComplete
        self.petService = PetService(context: PersistenceController.shared.container.viewContext)
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
                    
                    // 体重入力
                    TextField("体重（kg）", text: $weight)
                        .keyboardType(.decimalPad)
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
            .navigationTitle("ペット登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveNewPet()
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
    
    // 新しいペットを保存
    private func saveNewPet() {
        guard !name.isEmpty else {
            alertMessage = "ペットの名前を入力してください"
            showingAlert = true
            return
        }
        
        isSaving = true
        
        // 体重をDouble型に変換（入力がない場合はnil）
        let weightValue: Double? = {
            if let value = Double(weight.replacingOccurrences(of: ",", with: ".")) {
                return value
            }
            return nil
        }()
        
        // 画像データの取得
        let imageData = selectedImage?.jpegData(compressionQuality: 0.7)
        
        // ペット登録
        let pet = petService.createPet(
            name: name,
            type: type,
            breed: breed.isEmpty ? nil : breed,
            birthday: birthday,
            gender: gender,
            weight: weightValue,
            imageData: imageData,
            notes: notes.isEmpty ? nil : notes
        )
        
        isSaving = false
        
        // 作成したペットのモデルを作成
        let petModel = PetModel(entity: pet)
        
        // 完了コールバックを実行
        onComplete(petModel)
        
        // 画面を閉じる
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - プレビュー
struct AddPetView_Previews: PreviewProvider {
    static var previews: some View {
        AddPetView { _ in }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
