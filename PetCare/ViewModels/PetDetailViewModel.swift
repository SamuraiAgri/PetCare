// PetCare/ViewModels/PetDetailViewModel.swift

import Foundation
import Combine
import CoreData
import SwiftUI

class PetDetailViewModel: ObservableObject {
    // 外部から参照可能な状態
    @Published var pet: PetModel
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var healthRecords: [HealthRecordModel] = []
    @Published var vaccinations: [VaccinationModel] = []
    @Published var selectedTab: Int = 0
    
    // CoreData のコンテキストとサービス
    private let context: NSManagedObjectContext
    private let petService: PetService
    private let healthRecordService: HealthRecordService
    
    // 状態を保持する変数
    private var cancellables = Set<AnyCancellable>()
    
    init(pet: PetModel, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.pet = pet
        self.context = context
        self.petService = PetService(context: context)
        self.healthRecordService = HealthRecordService(context: context)
        
        // データをロード
        loadPetData()
    }
    
    // ペットデータを再ロード
    func loadPetData() {
        isLoading = true
        errorMessage = nil
        
        if let petEntity = petService.fetchPet(byId: pet.id) {
            // ペットデータの更新
            self.pet = PetModel(entity: petEntity)
            
            // 健康記録の取得
            self.healthRecords = healthRecordService.fetchHealthRecords(forPet: petEntity)
                .map { HealthRecordModel(entity: $0) }
            
            // ワクチン接種履歴の取得
            let vaccinationRequest: NSFetchRequest<Vaccination> = Vaccination.fetchRequest()
            vaccinationRequest.predicate = NSPredicate(format: "pet == %@", petEntity)
            vaccinationRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Vaccination.date, ascending: false)]
            
            do {
                let results = try context.fetch(vaccinationRequest)
                self.vaccinations = results.map { VaccinationModel(entity: $0) }
            } catch {
                errorMessage = "ワクチンデータの取得に失敗しました: \(error.localizedDescription)"
            }
            
            isLoading = false
        } else {
            errorMessage = "ペットデータの取得に失敗しました"
            isLoading = false
        }
    }
    
    // ペット情報の更新
    func updatePet(name: String, type: String, breed: String?, birthday: Date?, gender: String?, imageData: Data?, notes: String?) {
        isLoading = true
        errorMessage = nil
        
        if let petEntity = petService.fetchPet(byId: pet.id) {
            petService.updatePet(
                pet: petEntity,
                name: name,
                type: type,
                breed: breed,
                birthday: birthday,
                gender: gender,
                weight: pet.weight,
                imageData: imageData,
                notes: notes
            )
            
            // ペットデータを再ロード
            loadPetData()
        } else {
            errorMessage = "ペットデータの更新に失敗しました"
            isLoading = false
        }
    }
    
    // 体重の更新
    func updateWeight(weight: Double) {
        isLoading = true
        errorMessage = nil
        
        if let petEntity = petService.fetchPet(byId: pet.id) {
            // 健康記録を追加し体重を更新
            petService.updatePetWeight(pet: petEntity, weight: weight)
            
            // ペットデータを再ロード
            loadPetData()
        } else {
            errorMessage = "体重の更新に失敗しました"
            isLoading = false
        }
    }
    
    // 健康記録の追加
    func addHealthRecord(date: Date, weight: Double?, temperature: Double?, symptoms: String?, medications: String?, notes: String?) {
        isLoading = true
        errorMessage = nil
        
        if let petEntity = petService.fetchPet(byId: pet.id) {
            let _ = healthRecordService.createHealthRecord(
                pet: petEntity,
                date: date,
                weight: weight,
                temperature: temperature,
                symptoms: symptoms,
                medications: medications,
                notes: notes
            )
            
            // ペットデータを再ロード
            loadPetData()
        } else {
            errorMessage = "健康記録の追加に失敗しました"
            isLoading = false
        }
    }
    
    // 健康記録の削除
    func deleteHealthRecord(id: UUID) {
        if let record = fetchHealthRecordEntity(id: id) {
            healthRecordService.deleteHealthRecord(record: record)
            // データを再ロード
            loadPetData()
        }
    }
    
    // 予防接種記録の追加
    func addVaccination(name: String, date: Date, expiryDate: Date?, vetName: String?, clinicName: String?, notes: String?, nextDueDate: Date?) {
        isLoading = true
        errorMessage = nil
        
        if let petEntity = petService.fetchPet(byId: pet.id) {
            let vaccination = Vaccination(context: context)
            vaccination.id = UUID()
            vaccination.name = name
            vaccination.date = date
            vaccination.expiryDate = expiryDate
            vaccination.vetName = vetName
            vaccination.clinicName = clinicName
            vaccination.notes = notes
            vaccination.nextDueDate = nextDueDate
            vaccination.pet = petEntity
            vaccination.createdAt = Date()
            vaccination.updatedAt = Date()
            
            do {
                try context.save()
                // データを再ロード
                loadPetData()
            } catch {
                errorMessage = "予防接種記録の追加に失敗しました: \(error.localizedDescription)"
                isLoading = false
            }
        } else {
            errorMessage = "予防接種記録の追加に失敗しました"
            isLoading = false
        }
    }
    
    // 予防接種記録の削除
    func deleteVaccination(id: UUID) {
        let request: NSFetchRequest<Vaccination> = Vaccination.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let vaccination = results.first {
                context.delete(vaccination)
                try context.save()
                // データを再ロード
                loadPetData()
            }
        } catch {
            errorMessage = "予防接種記録の削除に失敗しました: \(error.localizedDescription)"
        }
    }
    
    // ID から健康記録エンティティを取得
    private func fetchHealthRecordEntity(id: UUID) -> HealthRecord? {
        return healthRecordService.fetchHealthRecord(byId: id)
    }
    
    // 体重履歴のチャートデータ
    var weightChartData: [(date: Date, weight: Double)] {
        return healthRecords
            .filter { $0.weight != nil }
            .sorted { $0.date < $1.date }
            .map { (date: $0.date, weight: $0.weight!) }
    }
    
    // 最近の健康記録（最大5件）
    var recentHealthRecords: [HealthRecordModel] {
        return Array(healthRecords.prefix(5))
    }
    
    // 最近の予防接種（最大3件）
    var recentVaccinations: [VaccinationModel] {
        return Array(vaccinations.prefix(3))
    }
    
    // 次回のワクチン接種予定
    var upcomingVaccinations: [VaccinationModel] {
        return vaccinations
            .filter { $0.nextDueDate != nil && $0.nextDueDate! > Date() }
            .sorted { $0.nextDueDate! < $1.nextDueDate! }
    }
    
    // 期限切れや期限が近いワクチン
    var expiringVaccinations: [VaccinationModel] {
        return vaccinations
            .filter { $0.isExpired || $0.isExpiryNear }
            .sorted {
                if $0.isExpired && !$1.isExpired {
                    return true
                } else if !$0.isExpired && $1.isExpired {
                    return false
                } else if let exp0 = $0.expiryDate, let exp1 = $1.expiryDate {
                    return exp0 < exp1
                } else {
                    return false
                }
            }
    }
    
    // 症状のある健康記録
    var healthIssues: [HealthRecordModel] {
        return healthRecords.filter { $0.hasSymptoms }
    }
    
    // 健康記録があるかどうか
    var hasHealthRecords: Bool {
        return !healthRecords.isEmpty
    }
    
    // 予防接種記録があるかどうか
    var hasVaccinations: Bool {
        return !vaccinations.isEmpty
    }
    
    // 健康上の問題があるかどうか
    var hasHealthIssues: Bool {
        return !healthIssues.isEmpty
    }
    
    // 注意が必要なワクチン接種があるかどうか
    var hasVaccinationIssues: Bool {
        return !expiringVaccinations.isEmpty || !upcomingVaccinations.isEmpty
    }
}
