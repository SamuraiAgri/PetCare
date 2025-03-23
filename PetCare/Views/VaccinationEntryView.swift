// PetCare/Views/VaccinationEntryView.swift

import SwiftUI
import CoreData

struct VaccinationEntryView: View {
    // ペットデータ
    private let pet: PetModel?
    
    // 状態変数
    @State private var vaccinations: [VaccinationModel] = []
    @State private var showAddVaccinationSheet = false
    
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
                    Text("\(pet.name)のワクチン記録")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddVaccinationSheet = true
                    }) {
                        Label("追加", systemImage: "plus")
                    }
                }
                .padding(.horizontal)
                
                if vaccinations.isEmpty {
                    EmptyStateView(
                        title: "ワクチン記録がありません",
                        message: "ワクチン接種の記録を追加して、\(pet.name)の健康管理をしましょう。",
                        iconName: "syringe",
                        buttonTitle: "ワクチン記録を追加",
                        action: {
                            showAddVaccinationSheet = true
                        }
                    )
                    .padding()
                } else {
                    // ワクチン記録一覧
                    ForEach(vaccinations) { vaccination in
                        CardView {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "syringe")
                                        .foregroundColor(vaccination.status.color)
                                    
                                    Text(vaccination.name)
                                        .font(.headline)
                                        .foregroundColor(.primaryTextColor)
                                    
                                    Spacer()
                                    
                                    TagView(
                                        text: vaccination.status.label,
                                        color: vaccination.status.color
                                    )
                                }
                                
                                Divider()
                                
                                // 接種日と有効期限
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("接種日")
                                            .font(.caption)
                                            .foregroundColor(.secondaryTextColor)
                                        
                                        Text(vaccination.dateText)
                                            .font(.body)
                                            .foregroundColor(.primaryTextColor)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if let expiryDateText = vaccination.expiryDateText {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("有効期限")
                                                .font(.caption)
                                                .foregroundColor(.secondaryTextColor)
                                            
                                            Text(expiryDateText)
                                                .font(.body)
                                                .foregroundColor(vaccination.isExpired ? .errorColor : .primaryTextColor)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                
                                // 次回接種予定
                                if let nextDueDateText = vaccination.nextDueDateText {
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("次回接種予定")
                                                .font(.caption)
                                                .foregroundColor(.secondaryTextColor)
                                            
                                            Text(nextDueDateText)
                                                .font(.body)
                                                .foregroundColor(vaccination.isNextDueNear ? .warningColor : .primaryTextColor)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
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
        .sheet(isPresented: $showAddVaccinationSheet) {
            AddVaccinationView(pet: pet) { _ in
                loadVaccinations(for: pet)
            }
        }
        .onAppear {
            loadVaccinations(for: pet)
        }
    }
    
    // ワクチン記録を読み込み
    private func loadVaccinations(for pet: PetModel) {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            let request: NSFetchRequest<Vaccination> = Vaccination.fetchRequest()
            let petRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
            petRequest.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
            
            if let petEntity = try context.fetch(petRequest).first {
                request.predicate = NSPredicate(format: "pet == %@", petEntity)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \Vaccination.date, ascending: false)]
                
                let results = try context.fetch(request)
                self.vaccinations = results.map { VaccinationModel(entity: $0) }
            }
        } catch {
            print("ワクチン記録の取得エラー: \(error)")
        }
    }
}

struct VaccinationEntryView_Previews: PreviewProvider {
    static var previews: some View {
        VaccinationEntryView(pet: PetModel.sampleData[0])
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
