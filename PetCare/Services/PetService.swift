// PetCare/Services/PetService.swift

import Foundation
import CoreData
import SwiftUI

class PetService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - ペット作成
    func createPet(name: String, type: String, breed: String?, birthday: Date?, gender: String?, weight: Double?, imageData: Data?, notes: String?) -> Pet {
        let pet = Pet(context: context)
        pet.id = UUID()
        pet.name = name
        pet.type = type
        pet.breed = breed
        pet.birthday = birthday
        pet.gender = gender
        pet.weight = weight ?? 0
        pet.imageData = imageData
        pet.notes = notes
        pet.createdAt = Date()
        pet.updatedAt = Date()
        
        save()
        return pet
    }
    
    // MARK: - ペット更新
    func updatePet(pet: Pet, name: String, type: String, breed: String?, birthday: Date?, gender: String?, weight: Double?, imageData: Data?, notes: String?) {
        pet.name = name
        pet.type = type
        pet.breed = breed
        pet.birthday = birthday
        pet.gender = gender
        pet.weight = weight ?? pet.weight
        
        // 新しい画像データがある場合のみ更新
        if let imageData = imageData {
            pet.imageData = imageData
        }
        
        pet.notes = notes
        pet.updatedAt = Date()
        
        save()
    }
    
    // MARK: - ペット削除
    func deletePet(pet: Pet) {
        context.delete(pet)
        save()
    }
    
    // MARK: - すべてのペット取得
    func fetchAllPets() -> [Pet] {
        let request: NSFetchRequest<Pet> = Pet.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("ペットデータの取得エラー: \(error)")
            return []
        }
    }
    
    // MARK: - IDによるペット取得
    func fetchPet(byId id: UUID) -> Pet? {
        let request: NSFetchRequest<Pet> = Pet.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("ペットデータの取得エラー: \(error)")
            return nil
        }
    }
    
    // MARK: - ペットの種類による検索
    func fetchPets(byType type: String) -> [Pet] {
        let request: NSFetchRequest<Pet> = Pet.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("ペットデータの取得エラー: \(error)")
            return []
        }
    }
    
    // MARK: - ペットの名前による検索
    func searchPets(byName searchText: String) -> [Pet] {
        let request: NSFetchRequest<Pet> = Pet.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("ペットデータの検索エラー: \(error)")
            return []
        }
    }
    
    // MARK: - 体重の更新
    func updatePetWeight(pet: Pet, weight: Double) {
        // 健康記録も追加
        let healthRecord = HealthRecord(context: context)
        healthRecord.id = UUID()
        healthRecord.date = Date()
        healthRecord.weight = weight
        healthRecord.pet = pet
        healthRecord.createdAt = Date()
        healthRecord.updatedAt = Date()
        
        // ペットの最新の体重を更新
        pet.weight = weight
        pet.updatedAt = Date()
        
        save()
    }
    
    // MARK: - 保存処理
    private func save() {
        do {
            try context.save()
        } catch {
            print("ペットデータの保存エラー: \(error)")
        }
    }
}
