// PetCare/ViewModels/PetListViewModel.swift

import Foundation
import Combine
import CoreData
import SwiftUI

class PetListViewModel: ObservableObject {
    // 外部から参照可能な状態
    @Published var pets: [PetModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedPetType: String? = nil
    
    // CoreData のコンテキストとサービス
    private let context: NSManagedObjectContext
    private let petService: PetService
    
    // 状態を保持する変数
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.petService = PetService(context: context)
        
        // searchText と selectedPetType が変更されたときにフィルタリングを実行
        Publishers.CombineLatest($searchText, $selectedPetType.eraseToAnyPublisher())
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] (searchText, selectedType) in
                self?.filterPets(searchText: searchText, petType: selectedType)
            }
            .store(in: &cancellables)
        
        // 初期データをロード
        loadPets()
    }
    
    // ペットの一覧を取得
    func loadPets() {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
            
            let results = try context.fetch(fetchRequest)
            self.pets = results.map { PetModel(entity: $0) }
            
            isLoading = false
        } catch {
            errorMessage = "ペットデータの取得に失敗しました: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // ペットの追加
    func addPet(name: String, type: String, breed: String?, birthday: Date?, gender: String?, weight: Double?, imageData: Data?, notes: String?) {
        isLoading = true
        errorMessage = nil
        
        let _ = petService.createPet(
            name: name,
            type: type,
            breed: breed,
            birthday: birthday,
            gender: gender,
            weight: weight,
            imageData: imageData,
            notes: notes
        )
        
        // 一覧を再読み込み
        loadPets()
    }
    
    // ペットの削除
    func deletePet(at indexSet: IndexSet) {
        for index in indexSet {
            let petModel = pets[index]
            if let pet = fetchPetEntity(id: petModel.id) {
                petService.deletePet(pet: pet)
            }
        }
        
        // 一覧を再読み込み
        loadPets()
    }
    
    // ペットの削除（ID指定）
    func deletePet(id: UUID) {
        if let pet = fetchPetEntity(id: id) {
            petService.deletePet(pet: pet)
            // 一覧を再読み込み
            loadPets()
        }
    }
    
    // ID からペットエンティティを取得
    private func fetchPetEntity(id: UUID) -> Pet? {
        return petService.fetchPet(byId: id)
    }
    
    // 検索とフィルタリング
    private func filterPets(searchText: String, petType: String?) {
        isLoading = true
        errorMessage = nil
        
        do {
            var predicates: [NSPredicate] = []
            
            // 検索テキストによるフィルタリング
            if !searchText.isEmpty {
                predicates.append(NSPredicate(format: "name CONTAINS[cd] %@ OR breed CONTAINS[cd] %@", searchText, searchText))
            }
            
            // ペットタイプによるフィルタリング
            if let petType = petType, !petType.isEmpty {
                predicates.append(NSPredicate(format: "type == %@", petType))
            }
            
            let fetchRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
            
            // 条件が指定されている場合のみ適用
            if !predicates.isEmpty {
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
            
            let results = try context.fetch(fetchRequest)
            self.pets = results.map { PetModel(entity: $0) }
            
            isLoading = false
        } catch {
            errorMessage = "ペットデータのフィルタリングに失敗しました: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // ペットタイプのリストを取得
    var petTypes: [String] {
        return ["dog", "cat", "bird", "fish", "other"]
    }
    
    // ペットタイプの日本語名を取得
    func petTypeName(for type: String) -> String {
        switch type.lowercased() {
        case "dog":
            return "犬"
        case "cat":
            return "猫"
        case "bird":
            return "鳥"
        case "fish":
            return "魚"
        case "other":
            return "その他"
        default:
            return type
        }
    }
    
    // ペットの数
    var petCount: Int {
        return pets.count
    }
    
    // ペットタイプ別の数
    func countByType(type: String) -> Int {
        return pets.filter { $0.type.lowercased() == type.lowercased() }.count
    }
    
    // 検索結果があるかどうか
    var hasSearchResults: Bool {
        return !pets.isEmpty
    }
    
    // 検索やフィルタリングが適用されているかどうか
    var isFiltering: Bool {
        return !searchText.isEmpty || selectedPetType != nil
    }
    
    // フィルタリングをリセット
    func resetFilters() {
        searchText = ""
        selectedPetType = nil
    }
}
