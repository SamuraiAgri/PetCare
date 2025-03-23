// PetCare/Views/MealScheduleView.swift

import SwiftUI
import CoreData

struct MealScheduleView: View {
    // ペットデータ
    private let pet: PetModel?
    
    // 状態変数
    @State private var mealSchedules: [MealScheduleModel] = []
    @State private var showAddScheduleSheet = false
    
    // 初期化
    init(pet: PetModel?) {
        self.pet = pet
    }
    
    var body: some View {
        if let pet = pet {
            listContent(for: pet)
        } else {
            Text("ペットが選択されていません")
                .foregroundColor(.secondaryTextColor)
                .padding()
        }
    }
    
    private func listContent(for pet: PetModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // ヘッダー
                HStack {
                    Text("\(pet.name)の給餌スケジュール")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddScheduleSheet = true
                    }) {
                        Label("追加", systemImage: "plus")
                    }
                }
                .padding(.horizontal)
                
                if mealSchedules.isEmpty {
                    EmptyStateView(
                        title: "給餌スケジュールがありません",
                        message: "給餌スケジュールを追加して、\(pet.name)の食事を管理しましょう。",
                        iconName: "bowl.fill",
                        buttonTitle: "スケジュールを追加",
                        action: {
                            showAddScheduleSheet = true
                        }
                    )
                    .padding()
                } else {
                    // スケジュール一覧
                    ForEach(mealSchedules) { meal in
                        CardView {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(meal.name)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text(meal.timeText)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.secondaryColor.opacity(0.2))
                                        .foregroundColor(.secondaryColor)
                                        .cornerRadius(10)
                                }
                                
                                Divider()
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("食事内容")
                                            .font(.caption)
                                            .foregroundColor(.secondaryTextColor)
                                        
                                        Text(meal.foodType)
                                            .font(.body)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("量")
                                            .font(.caption)
                                            .foregroundColor(.secondaryTextColor)
                                        
                                        Text(meal.amountText)
                                            .font(.body)
                                    }
                                }
                                
                                HStack {
                                    Text(meal.weekdaysText)
                                        .font(.footnote)
                                        .foregroundColor(.secondaryTextColor)
                                    
                                    Spacer()
                                    
                                    if meal.isActive {
                                        Text("有効")
                                            .font(.caption)
                                            .foregroundColor(.successColor)
                                    } else {
                                        Text("無効")
                                            .font(.caption)
                                            .foregroundColor(.errorColor)
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadMealSchedules(for: pet)
        }
    }
    
    // 給餌スケジュールを読み込み
    private func loadMealSchedules(for pet: PetModel) {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            let request: NSFetchRequest<MealSchedule> = MealSchedule.fetchRequest()
            let petRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
            petRequest.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
            
            if let petEntity = try context.fetch(petRequest).first {
                request.predicate = NSPredicate(format: "pet == %@", petEntity)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \MealSchedule.time, ascending: true)]
                
                let results = try context.fetch(request)
                self.mealSchedules = results.map { MealScheduleModel(entity: $0) }
            }
        } catch {
            print("給餌スケジュールの取得エラー: \(error)")
        }
    }
}

struct MealScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        MealScheduleView(pet: PetModel.sampleData[0])
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
