// PetCare/Views/HealthRecordListView.swift

import SwiftUI

struct HealthRecordListView: View {
    // ビューモデル
    @StateObject private var viewModel: PetDetailViewModel
    
    // 状態変数
    @State private var showAddHealthRecordSheet = false
    @State private var selectedFilter: HealthRecordFilter = .all
    @State private var searchText = ""
    
    // フィルターオプション
    enum HealthRecordFilter: String, CaseIterable, Identifiable {
        case all = "すべて"
        case recent = "最近"
        case symptoms = "症状あり"
        case withTemperature = "体温記録あり"
        
        var id: String { self.rawValue }
    }
    
    // 初期化
    init(pet: PetModel) {
        _viewModel = StateObject(wrappedValue: PetDetailViewModel(pet: pet))
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            
            if viewModel.healthRecords.isEmpty {
                // 記録がない場合
                EmptyStateView(
                    title: "健康記録がありません",
                    message: "健康記録を追加して、\(viewModel.pet.name)の健康状態を管理しましょう。",
                    iconName: "heart.text.square",
                    buttonTitle: "健康記録を追加",
                    action: {
                        showAddHealthRecordSheet = true
                    }
                )
            } else {
                // 記録一覧
                VStack(spacing: 0) {
                    // フィルターセグメント
                    Picker("フィルター", selection: $selectedFilter) {
                        ForEach(HealthRecordFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // 記録一覧
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredRecords) { record in
                                healthRecordCard(record: record)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle("\(viewModel.pet.name)の健康記録")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddHealthRecordSheet = true
                }) {
                    Label("追加", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddHealthRecordSheet) {
            AddHealthRecordView(pet: viewModel.pet) { _ in
                viewModel.loadPetData()
            }
        }
        .searchable(text: $searchText, prompt: "症状や薬を検索")
        .onAppear {
            viewModel.loadPetData()
        }
    }
    
    // フィルター適用済みの記録
    private var filteredRecords: [HealthRecordModel] {
        var records = viewModel.healthRecords
        
        // 検索テキストによるフィルタリング
        if !searchText.isEmpty {
            records = records.filter { record in
                let symptoms = record.symptoms?.lowercased() ?? ""
                let medications = record.medications?.lowercased() ?? ""
                let notes = record.notes?.lowercased() ?? ""
                let searchLower = searchText.lowercased()
                
                return symptoms.contains(searchLower) ||
                       medications.contains(searchLower) ||
                       notes.contains(searchLower)
            }
        }
        
        // 選択されたフィルターによるフィルタリング
        switch selectedFilter {
        case .all:
            return records
        case .recent:
            // 最近2週間の記録
            let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
            return records.filter { $0.date >= twoWeeksAgo }
        case .symptoms:
            // 症状がある記録
            return records.filter { $0.hasSymptoms }
        case .withTemperature:
            // 体温記録がある記録
            return records.filter { $0.temperature != nil }
        }
    }
    
    // 健康記録カード
    private func healthRecordCard(record: HealthRecordModel) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(record.dateText)
                        .font(.headline)
                        .foregroundColor(.primaryTextColor)
                    
                    Spacer()
                    
                    StatusIndicator(
                        status: record.healthStatus == .good ? .success :
                               (record.healthStatus == .warning ? .warning :
                               (record.healthStatus == .alert ? .error : .info)),
                        text: record.healthStatus == .good ? "良好" :
                             (record.healthStatus == .warning ? "注意" :
                             (record.healthStatus == .alert ? "要確認" : "不明"))
                    )
                }
                
                Divider()
                
                // 体重と体温
                HStack(spacing: 16) {
                    if let weightText = record.weightText {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("体重")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                            
                            Text(weightText)
                                .font(.body)
                                .foregroundColor(.primaryTextColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let temperatureText = record.temperatureText {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("体温")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                            
                            HStack(spacing: 4) {
                                Text(temperatureText)
                                    .font(.body)
                                    .foregroundColor(.primaryTextColor)
                                
                                if let isNormal = record.isTemperatureNormal {
                                    Image(systemName: isNormal ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                        .foregroundColor(isNormal ? .successColor : .errorColor)
                                        .font(.caption)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // 症状
                if record.hasSymptoms {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("症状")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                        
                        Text(record.symptoms ?? "")
                            .font(.body)
                            .foregroundColor(.primaryTextColor)
                    }
                }
                
                // 投薬
                if record.hasMedications {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("投薬")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                        
                        Text(record.medications ?? "")
                            .font(.body)
                            .foregroundColor(.primaryTextColor)
                    }
                }
                
                // メモ
                if let notes = record.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("メモ")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                        
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.primaryTextColor)
                    }
                }
            }
            .padding()
        }
        .contextMenu {
            Button(role: .destructive, action: {
                viewModel.deleteHealthRecord(id: record.id)
            }) {
                Label("削除", systemImage: "trash")
            }
        }
    }
}

// MARK: - プレビュー
struct HealthRecordListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthRecordListView(pet: PetModel.sampleData[0])
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
