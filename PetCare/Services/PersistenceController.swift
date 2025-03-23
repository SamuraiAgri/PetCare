// PetCare/Services/PersistenceController.swift

import CoreData

struct PersistenceController {
    // シングルトンインスタンス
    static let shared = PersistenceController()
    
    // プレビュー用
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // サンプルデータの作成
        let viewContext = controller.container.viewContext
        
        // サンプルペットの作成
        let pet1 = Pet(context: viewContext)
        pet1.id = UUID()
        pet1.name = "モカ"
        pet1.type = "dog"
        pet1.breed = "柴犬"
        pet1.birthday = Calendar.current.date(byAdding: .year, value: -3, to: Date())
        pet1.gender = "female"
        pet1.weight = 8.5
        pet1.notes = "とても元気な柴犬です。散歩が大好きです。"
        pet1.createdAt = Date()
        pet1.updatedAt = Date()
        
        let pet2 = Pet(context: viewContext)
        pet2.id = UUID()
        pet2.name = "ミケ"
        pet2.type = "cat"
        pet2.breed = "三毛猫"
        pet2.birthday = Calendar.current.date(byAdding: .month, value: -8, to: Date())
        pet2.gender = "male"
        pet2.weight = 4.2
        pet2.notes = "人懐っこい猫です。いつもソファで寝ています。"
        pet2.createdAt = Date()
        pet2.updatedAt = Date()
        
        // サンプル健康記録の作成
        let health1 = HealthRecord(context: viewContext)
        health1.id = UUID()
        health1.date = Date()
        health1.weight = 8.5
        health1.temperature = 38.5
        health1.notes = "元気です。"
        health1.pet = pet1
        health1.createdAt = Date()
        health1.updatedAt = Date()
        
        // サンプル予防接種の作成
        let vaccination1 = Vaccination(context: viewContext)
        vaccination1.id = UUID()
        vaccination1.name = "混合ワクチン"
        vaccination1.date = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        vaccination1.expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: vaccination1.date!)
        vaccination1.nextDueDate = Calendar.current.date(byAdding: .month, value: 9, to: Date())
        vaccination1.vetName = "鈴木先生"
        vaccination1.clinicName = "やまと動物病院"
        vaccination1.pet = pet1
        vaccination1.createdAt = Date()
        vaccination1.updatedAt = Date()
        
        // サンプル食事スケジュールの作成
        let meal1 = MealSchedule(context: viewContext)
        meal1.id = UUID()
        meal1.name = "朝食"
        meal1.time = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date())!
        meal1.amount = 150
        meal1.foodType = "ドライフード"
        meal1.isActive = true
        meal1.daysOfWeek = "1,2,3,4,5,6,7"
        meal1.pet = pet1
        meal1.createdAt = Date()
        meal1.updatedAt = Date()
        
        let meal2 = MealSchedule(context: viewContext)
        meal2.id = UUID()
        meal2.name = "夕食"
        meal2.time = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
        meal2.amount = 150
        meal2.foodType = "ドライフード"
        meal2.isActive = true
        meal2.daysOfWeek = "1,2,3,4,5,6,7"
        meal2.pet = pet1
        meal2.createdAt = Date()
        meal2.updatedAt = Date()
        
        // サンプル用品の作成
        let supply1 = Supply(context: viewContext)
        supply1.id = UUID()
        supply1.name = "プレミアムドッグフード"
        supply1.type = "food"
        supply1.quantity = 3000
        supply1.unit = "g"
        supply1.purchaseDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        supply1.expiryDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())
        supply1.alertThreshold = 500
        supply1.pet = pet1
        supply1.createdAt = Date()
        supply1.updatedAt = Date()
        
        // サンプル予約の作成
        let appointment1 = Appointment(context: viewContext)
        appointment1.id = UUID()
        appointment1.title = "定期健康診断"
        appointment1.type = "vet"
        appointment1.date = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        
        // Date型に変更されているので、Dateオブジェクトを直接代入
        appointment1.time = Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: appointment1.date!)!
        
        appointment1.duration = 60
        appointment1.location = "やまと動物病院"
        appointment1.notes = "予防接種も行います"
        appointment1.isDone = false
        appointment1.reminderTime = 60
        appointment1.pet = pet1
        appointment1.createdAt = Date()
        appointment1.updatedAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    // Core Data stack
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PetCare")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Core Data 保存ヘルパーメソッド
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("CoreData保存エラー: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - 新規コンテキスト取得
    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
}
