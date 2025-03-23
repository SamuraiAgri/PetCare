// PetCare/Views/PetListView.swift

import SwiftUI

struct PetListView: View {
    // ビューモデル
    @StateObject private var viewModel = PetListViewModel()
    
    // 環境オブジェクト
    @EnvironmentObject var appState: AppState
    
    // 状態変数
    @State private var showAddPetSheet = false
    @State private var showFilterOptions = false
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if viewModel.petCount == 0 {
                EmptyStateView(
                    title: "ペットがいません",
                    message: "まずは、あなたのペットを登録しましょう。",
                    iconName: "pawprint.circle",
                    buttonTitle: "ペットを登録する",
                    action: {
                        showAddPetSheet = true
                    }
                )
            } else {
                petListContent
            }
        }
        .navigationTitle("ペット一覧")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        showFilterOptions.toggle()
                    }) {
                        Label("絞り込み", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button(action: {
                        showAddPetSheet = true
                    }) {
                        Label("追加", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPetSheet) {
            AddPetView { newPet in
                viewModel.loadPets()
                if let newPet = newPet {
                    // アプリの状態も更新
                    appState.selectPet(newPet.id)
                }
            }
        }
        .alert(item: Binding(
            get: {
                viewModel.errorMessage.map { ErrorWrapper(error: $0) }
            },
            set: { _ in viewModel.errorMessage = nil }
        )) { errorWrapper in
            Alert(
                title: Text("エラー"),
                message: Text(errorWrapper.error),
                dismissButton: .default(Text("OK"))
            )
        }
        .refreshable {
            viewModel.loadPets()
        }
        .actionSheet(isPresented: $showFilterOptions) {
            filterActionSheet
        }
        .searchable(text: $viewModel.searchText, prompt: "ペットを検索")
    }
    
    // ペット一覧表示
    private var petListContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isFiltering {
                    filterInfoBar
                }
                
                ForEach(viewModel.pets) { pet in
                    NavigationLink(destination: PetDetailView(pet: pet)) {
                        petListItem(pet: pet)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    // ペット一覧アイテム
    private func petListItem(pet: PetModel) -> some View {
        CardView {
            HStack(spacing: 16) {
                // ペットのアバター画像
                PetAvatarView(
                    imageData: pet.imageData,
                    name: pet.name,
                    size: 60,
                    petType: pet.type
                )
                
                // ペット情報
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(pet.name)
                            .font(.title3)
                            .foregroundColor(.primaryTextColor)
                        
                        Spacer()
                        
                        TagView(
                            text: pet.typeText,
                            color: pet.typeColor
                        )
                    }
                    
                    HStack(spacing: 12) {
                        if let breed = pet.breed, !breed.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "pawprint")
                                    .font(.caption)
                                    .foregroundColor(.secondaryTextColor)
                                
                                Text(breed)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryTextColor)
                            }
                        }
                        
                        if pet.birthday != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.secondaryTextColor)
                                
                                Text(pet.age)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryTextColor)
                            }
                        }
                        
                        if pet.gender != nil {
                            HStack(spacing: 4) {
                                Image(systemName: pet.gender == "male" ? "mars" : "venus")
                                    .font(.caption)
                                    .foregroundColor(.secondaryTextColor)
                                
                                Text(pet.genderText)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryTextColor)
                            }
                        }
                    }
                    
                    if pet.weight != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "scalemass")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                            
                            Text(pet.weightText)
                                .font(.subheadline)
                                .foregroundColor(.secondaryTextColor)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // フィルター情報バー
    private var filterInfoBar: some View {
        HStack {
            if !viewModel.searchText.isEmpty {
                Text("検索: \"\(viewModel.searchText)\"")
                    .font(.caption)
                    .foregroundColor(.primaryTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            
            if let selectedType = viewModel.selectedPetType {
                Text("種類: \(viewModel.petTypeName(for: selectedType))")
                    .font(.caption)
                    .foregroundColor(.primaryTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.resetFilters()
            }) {
                Text("リセット")
                    .font(.caption)
                    .foregroundColor(.primaryColor)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // フィルターのアクションシート
    private var filterActionSheet: ActionSheet {
        var buttons: [ActionSheet.Button] = []
        
        // ペットタイプのフィルター選択肢
        for type in viewModel.petTypes {
            buttons.append(.default(
                Text(viewModel.petTypeName(for: type)),
                action: {
                    viewModel.selectedPetType = (viewModel.selectedPetType == type) ? nil : type
                }
            ))
        }
        
        buttons.append(.cancel(Text("キャンセル")))
        
        return ActionSheet(
            title: Text("ペットの種類で絞り込み"),
            message: nil,
            buttons: buttons
        )
    }
}

// エラーラッパー（アラート表示用）
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
}

// MARK: - プレビュー
struct PetListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PetListView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AppState())
        }
    }
}
