// PetCare/ViewModels/HomeViewModel.swift

import Foundation
import Combine
import CoreData
import SwiftUI

class HomeViewModel: ObservableObject {
    // 外部から参照可能な状態
    @Published var pets: [PetModel] = []
    @Published var upcomingAppointments: [AppointmentModel] = []
    @Published var vaccinationAlerts: [(pet: PetModel, vaccination: VaccinationModel)] = []
    @Published var todayFeedings: [(pet: PetModel, meal: MealScheduleModel)] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedPet: PetModel? = nil
    
    // CoreData のコンテキストとサービス
    private let context: NSManagedObjectContext
    private let petService: PetService
    
    // 状態を保持する変数
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.petService = PetService(context: context)
        
        // データをロード
        loadHomeData()
    }
    
    // ホーム画面データを読み込み
    func loadHomeData() {
        isLoading = true
        errorMessage = nil
        
        do {
            // ペットデータの取得
            let fetchRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
            
            let results = try context.fetch(fetchRequest)
            self.pets = results.map { PetModel(entity: $0) }
            
            // 最初に登録されたペットを選択状態にする（ペットがある場合）
            if !self.pets.isEmpty && self.selectedPet == nil {
                self.selectedPet = self.pets.first
            }
            
            loadAppointments()
            loadVaccinationAlerts()
            loadTodayFeedings()
            
            isLoading = false
        } catch {
            errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // ペットを選択
    func selectPet(_ pet: PetModel) {
        self.selectedPet = pet
        // 選択したペットに関連するデータを再読み込み
        loadAppointments()
        loadVaccinationAlerts()
        loadTodayFeedings()
    }
    
    // 次回のアポイントメントを取得
    private func loadAppointments() {
        do {
            var predicates: [NSPredicate] = []
            
            // 過去の予約を除外する
            predicates.append(NSPredicate(format: "date >= %@", Date() as NSDate))
            // 完了済みの予約を除外する
            predicates.append(NSPredicate(format: "isDone == NO"))
            
            // 特定のペットが選択されている場合
            if let selectedPet = selectedPet, let petEntity = petService.fetchPet(byId: selectedPet.id) {
                predicates.append(NSPredicate(format: "pet == %@", petEntity))
            }
            
            let fetchRequest: NSFetchRequest<Appointment> = Appointment.fetchRequest()
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Appointment.date, ascending: true)]
            fetchRequest.fetchLimit = 5  // 最大5件まで
            
            let results = try context.fetch(fetchRequest)
            self.upcomingAppointments = results.map { AppointmentModel(entity: $0) }
        } catch {
            print("予約データの取得エラー: \(error)")
        }
    }
    
    // ワクチンのアラートを取得
    private func loadVaccinationAlerts() {
        do {
            var petVaccinationAlerts: [(pet: PetModel, vaccination: VaccinationModel)] = []
            
            // 各ペットのワクチン情報を確認
            for pet in self.pets {
                // 特定のペットが選択されていて、現在のペットが選択されたペットでない場合はスキップ
                if let selectedPet = selectedPet, pet.id != selectedPet.id {
                    continue
                }
                
                if let petEntity = petService.fetchPet(byId: pet.id) {
                    let vaccinationRequest: NSFetchRequest<Vaccination> = Vaccination.fetchRequest()
                    vaccinationRequest.predicate = NSPredicate(format: "pet == %@", petEntity)
                    
                    let results = try context.fetch(vaccinationRequest)
                    let vaccinations = results.map { VaccinationModel(entity: $0) }
                    
                    // 期限切れか期限が近いワクチン、または次回接種が近いワクチンを抽出
                    for vaccination in vaccinations {
                        if vaccination.isExpired || vaccination.isExpiryNear || vaccination.isNextDueNear {
                            petVaccinationAlerts.append((pet: pet, vaccination: vaccination))
                        }
                    }
                }
            }
            
            // 期限切れ > 期限近い > 次回接種近い の順で並べ替え
            self.vaccinationAlerts = petVaccinationAlerts.sorted { (a, b) in
                let vaccA = a.vaccination
                let vaccB = b.vaccination
                
                if vaccA.isExpired && !vaccB.isExpired {
                    return true
                } else if !vaccA.isExpired && vaccB.isExpired {
                    return false
                } else if vaccA.isExpiryNear && !vaccB.isExpiryNear {
                    return true
                } else if !vaccA.isExpiryNear && vaccB.isExpiryNear {
                    return false
                } else if let daysA = vaccA.daysUntilExpiry, let daysB = vaccB.daysUntilExpiry {
                    return daysA < daysB
                } else {
                    return false
                }
            }
        } catch {
            print("ワクチンアラートの取得エラー: \(error)")
        }
    }
    
    // 今日の給餌スケジュールを取得
    private func loadTodayFeedings() {
        do {
            var todayMeals: [(pet: PetModel, meal: MealScheduleModel)] = []
            
            // 現在の曜日を取得（1=日曜日, 2=月曜日, ...）
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            let weekdayString = String(weekday)
            
            // 各ペットの給餌スケジュールを確認
            for pet in self.pets {
                // 特定のペットが選択されていて、現在のペットが選択されたペットでない場合はスキップ
                if let selectedPet = selectedPet, pet.id != selectedPet.id {
                    continue
                }
                
                if let petEntity = petService.fetchPet(byId: pet.id) {
                    let mealRequest: NSFetchRequest<MealSchedule> = MealSchedule.fetchRequest()
                    mealRequest.predicate = NSPredicate(format: "pet == %@ AND isActive == YES AND daysOfWeek CONTAINS %@", petEntity, weekdayString)
                    mealRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MealSchedule.time, ascending: true)]
                    
                    let results = try context.fetch(mealRequest)
                    let meals = results.map { MealScheduleModel(entity: $0) }
                    
                    for meal in meals {
                        todayMeals.append((pet: pet, meal: meal))
                    }
                }
            }
            
            // 時間順に並べ替え
            self.todayFeedings = todayMeals.sorted { (a, b) in
                // 時間のみを比較するため、両方の時間を今日の日付に合わせる
                let timeA = Calendar.current.dateComponents([.hour, .minute], from: a.meal.time)
                let timeB = Calendar.current.dateComponents([.hour, .minute], from: b.meal.time)
                
                var dateA = DateComponents()
                dateA.year = Calendar.current.component(.year, from: Date())
                dateA.month = Calendar.current.component(.month, from: Date())
                dateA.day = Calendar.current.component(.day, from: Date())
                dateA.hour = timeA.hour
                dateA.minute = timeA.minute
                
                var dateB = DateComponents()
                dateB.year = Calendar.current.component(.year, from: Date())
                dateB.month = Calendar.current.component(.month, from: Date())
                dateB.day = Calendar.current.component(.day, from: Date())
                dateB.hour = timeB.hour
                dateB.minute = timeB.minute
                
                guard let dateAFull = Calendar.current.date(from: dateA),
                      let dateBFull = Calendar.current.date(from: dateB) else {
                    return false
                }
                
                return dateAFull < dateBFull
            }
        } catch {
            print("給餌スケジュールの取得エラー: \(error)")
        }
    }
    
    // ペットの数
    var petCount: Int {
        return pets.count
    }
    
    // ペットが登録されているかどうか
    var hasPets: Bool {
        return !pets.isEmpty
    }
    
    // 今日の予定があるかどうか
    var hasTodayAppointments: Bool {
        if upcomingAppointments.isEmpty {
            return false
        }
        
        // 今日の予定があるかどうかを確認
        return upcomingAppointments.contains { appointment in
            return Calendar.current.isDateInToday(appointment.date)
        }
    }
    
    // 今日の予定
    var todayAppointments: [AppointmentModel] {
        return upcomingAppointments.filter { appointment in
            return Calendar.current.isDateInToday(appointment.date)
        }
    }
    
    // 注意が必要なワクチン接種があるかどうか
    var hasVaccinationAlerts: Bool {
        return !vaccinationAlerts.isEmpty
    }
    
    // 今日の給餌スケジュールがあるかどうか
    var hasTodayFeedings: Bool {
        return !todayFeedings.isEmpty
    }
    
    // 次の給餌スケジュール
    var nextFeeding: (pet: PetModel, meal: MealScheduleModel)? {
        let now = Date()
        
        // 現在時刻以降の給餌スケジュールを探す
        for feeding in todayFeedings {
            // 時間のみを比較するため、両方の時間を今日の日付に合わせる
            let mealTime = Calendar.current.dateComponents([.hour, .minute], from: feeding.meal.time)
            
            var dateComponents = DateComponents()
            dateComponents.year = Calendar.current.component(.year, from: now)
            dateComponents.month = Calendar.current.component(.month, from: now)
            dateComponents.day = Calendar.current.component(.day, from: now)
            dateComponents.hour = mealTime.hour
            dateComponents.minute = mealTime.minute
            
            if let date = Calendar.current.date(from: dateComponents), date > now {
                return feeding
            }
        }
        
        // 該当がない場合は最初の給餌スケジュールを返す
        return todayFeedings.first
    }
}
