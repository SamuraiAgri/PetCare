// PetCare/Services/HealthRecordService.swift

import Foundation
import CoreData
import SwiftUI

class HealthRecordService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - 健康記録の作成
    func createHealthRecord(pet: Pet, date: Date, weight: Double?, temperature: Double?, symptoms: String?, medications: String?, notes: String?) -> HealthRecord {
        let record = HealthRecord(context: context)
        record.id = UUID()
        record.pet = pet
        record.date = date
        record.weight = weight ?? 0
        record.temperature = temperature ?? 0
        record.symptoms = symptoms
        record.medications = medications
        record.notes = notes
        record.createdAt = Date()
        record.updatedAt = Date()
        
        // ペットの体重が指定された場合、ペットの最新の体重を更新
        if let weight = weight {
            pet.weight = weight
            pet.updatedAt = Date()
        }
        
        save()
        return record
    }
    
    // MARK: - 健康記録の更新
    func updateHealthRecord(record: HealthRecord, date: Date, weight: Double?, temperature: Double?, symptoms: String?, medications: String?, notes: String?) {
        record.date = date
        record.weight = weight ?? 0
        record.temperature = temperature ?? 0
        record.symptoms = symptoms
        record.medications = medications
        record.notes = notes
        record.updatedAt = Date()
        
        // ペットの体重が指定された場合、ペットの最新の体重を更新
        if let weight = weight, let pet = record.pet {
            pet.weight = weight
            pet.updatedAt = Date()
        }
        
        save()
    }
    
    // MARK: - 健康記録の削除
    func deleteHealthRecord(record: HealthRecord) {
        context.delete(record)
        save()
    }
    
    // MARK: - ペットに関連する健康記録の取得
    func fetchHealthRecords(forPet pet: Pet) -> [HealthRecord] {
        let request: NSFetchRequest<HealthRecord> = HealthRecord.fetchRequest()
        request.predicate = NSPredicate(format: "pet == %@", pet)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HealthRecord.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("健康記録の取得エラー: \(error)")
            return []
        }
    }
    
    // MARK: - 特定の期間の健康記録を取得
    func fetchHealthRecords(forPet pet: Pet, startDate: Date, endDate: Date) -> [HealthRecord] {
        let request: NSFetchRequest<HealthRecord> = HealthRecord.fetchRequest()
        request.predicate = NSPredicate(format: "pet == %@ AND date >= %@ AND date <= %@", pet, startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HealthRecord.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("健康記録の取得エラー: \(error)")
            return []
        }
    }
    
    // MARK: - IDによる健康記録の取得
    func fetchHealthRecord(byId id: UUID) -> HealthRecord? {
        let request: NSFetchRequest<HealthRecord> = HealthRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("健康記録の取得エラー: \(error)")
            return nil
        }
    }
    
    // MARK: - 体重履歴の取得
    func fetchWeightHistory(forPet pet: Pet, limit: Int = 10) -> [HealthRecord] {
        let request: NSFetchRequest<HealthRecord> = HealthRecord.fetchRequest()
        request.predicate = NSPredicate(format: "pet == %@ AND weight != nil", pet)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HealthRecord.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("体重履歴の取得エラー: \(error)")
            return []
        }
    }
    
    // MARK: - 症状による健康記録の検索
    func searchHealthRecords(forPet pet: Pet, symptoms: String) -> [HealthRecord] {
        let request: NSFetchRequest<HealthRecord> = HealthRecord.fetchRequest()
        request.predicate = NSPredicate(format: "pet == %@ AND symptoms CONTAINS[cd] %@", pet, symptoms)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HealthRecord.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("健康記録の検索エラー: \(error)")
            return []
        }
    }
    
    // MARK: - 月ごとの健康記録の要約取得
    func fetchMonthlyHealthSummary(forPet pet: Pet, year: Int, month: Int) -> [HealthRecord] {
        let calendar = Calendar.current
        
        // 指定された年月の最初の日
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        guard let startDate = calendar.date(from: components) else {
            return []
        }
        
        // 次の月の最初の日
        guard let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            return []
        }
        
        // 指定された月の健康記録を取得
        return fetchHealthRecords(forPet: pet, startDate: startDate, endDate: endDate)
    }
    
    // MARK: - 保存処理
    private func save() {
        do {
            try context.save()
        } catch {
            print("健康記録の保存エラー: \(error)")
        }
    }
}
