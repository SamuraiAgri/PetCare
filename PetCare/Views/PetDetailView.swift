// PetCare/Views/PetDetailView.swift

import SwiftUI
import Charts

struct PetDetailView: View {
    // ビューモデル
    @StateObject private var viewModel: PetDetailViewModel
    
    // 環境オブジェクト
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) private var presentationMode
    
    // 状態変数
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showAddHealthRecordSheet = false
    @State private var showAddVaccinationSheet = false
    @State private var showWeightEntrySheet = false
    
    // 初期化
    init(pet: PetModel) {
        _viewModel = StateObject(wrappedValue: PetDetailViewModel(pet: pet))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ペットのプロフィールセクション
                petProfileSection
                
                // タブセレクター
                tabSelector
                
                // 選択されたタブのコンテンツ
                tabContent
            }
            .padding(.horizontal)
        }
        .background(Color.backgroundColor.ignoresSafeArea())
        .navigationTitle(viewModel.pet.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("編集", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("ペットを削除"),
                message: Text("\(viewModel.pet.name)の情報をすべて削除しますか？この操作は元に戻せません。"),
                primaryButton: .destructive(Text("削除")) {
                    // ペット削除処理
                    let petId = viewModel.pet.id
                    // CoreData から削除
                    let petListViewModel = PetListViewModel()
                    petListViewModel.deletePet(id: petId)
                    // 選択中のペットを更新
                    if appState.selectedPetId == petId {
                        appState.selectedPetId = nil
                    }
                    // 前の画面に戻る
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPetView(pet: viewModel.pet) { updatedPet in
                if let updatedPet = updatedPet {
                    viewModel.loadPetData()
                }
            }
        }
        .sheet(isPresented: $showAddHealthRecordSheet) {
            AddHealthRecordView(pet: viewModel.pet) { _ in
                viewModel.loadPetData()
            }
        }
        .sheet(isPresented: $showAddVaccinationSheet) {
            AddVaccinationView(pet: viewModel.pet) { _ in
                viewModel.loadPetData()
            }
        }
        .sheet(isPresented: $showWeightEntrySheet) {
            WeightEntryView(pet: viewModel.pet, onComplete: { weight in
                if let weight = weight {
                    viewModel.updateWeight(weight: weight)
                }
            })
        }
        .onAppear {
            // ペットの最新データを取得
            viewModel.loadPetData()
        }
    }
    
    // MARK: - ペットプロフィールセクション
    private var petProfileSection: some View {
        CardView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    // ペットのアバター画像
                    PetAvatarView(
                        imageData: viewModel.pet.imageData,
                        name: viewModel.pet.name,
                        size: 90,
                        petType: viewModel.pet.type
                    )
                    
                    // ペット基本情報
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(viewModel.pet.name)
                                .font(.title2)
                                .foregroundColor(.primaryTextColor)
                            
                            Spacer()
                            
                            TagView(
                                text: viewModel.pet.typeText,
                                color: viewModel.pet.typeColor
                            )
                        }
                        
                        if let breed = viewModel.pet.breed, !breed.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "pawprint")
                                    .font(.caption)
                                    .foregroundColor(.secondaryTextColor)
                                
                                Text(breed)
                                    .font(.body)
                                    .foregroundColor(.secondaryTextColor)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            if viewModel.pet.birthday != nil {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.caption)
                                        .foregroundColor(.secondaryTextColor)
                                    
                                    Text(viewModel.pet.age)
                                        .font(.body)
                                        .foregroundColor(.secondaryTextColor)
                                }
                            }
                            
                            if viewModel.pet.gender != nil {
                                HStack(spacing: 4) {
                                    Image(systemName: viewModel.pet.gender == "male" ? "mars" : "venus")
                                        .font(.caption)
                                        .foregroundColor(.secondaryTextColor)
                                    
                                    Text(viewModel.pet.genderText)
                                        .font(.body)
                                        .foregroundColor(.secondaryTextColor)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // 体重セクション
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("体重")
                            .font(.headline)
                            .foregroundColor(.primaryTextColor)
                        
                        Text(viewModel.pet.weightText)
                            .font(.title2)
                            .foregroundColor(.primaryColor)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showWeightEntrySheet = true
                    }) {
                        Label("記録", systemImage: "plus.circle")
                            .font(.body)
                            .foregroundColor(.primaryColor)
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            .padding()
        }
    }
    
    // MARK: - タブセレクター
    private var tabSelector: some View {
        HStack {
            tabButton(title: "基本情報", index: 0)
            tabButton(title: "健康記録", index: 1)
            tabButton(title: "ワクチン", index: 2)
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // タブボタン
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            viewModel.selectedTab = index
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(viewModel.selectedTab == index ? .bold : .regular)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .foregroundColor(viewModel.selectedTab == index ? .white : .primaryTextColor)
                .background(viewModel.selectedTab == index ? Color.primaryColor : Color.clear)
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - タブコンテンツ
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case 0:
            basicInfoTab
        case 1:
            healthRecordsTab
        case 2:
            vaccinationsTab
        default:
            basicInfoTab
        }
    }
    
    // MARK: - 基本情報タブ
    private var basicInfoTab: some View {
        VStack(spacing: 16) {
            // メモ情報
            if let notes = viewModel.pet.notes, !notes.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("メモ")
                            .font(.headline)
                            .foregroundColor(.primaryTextColor)
                        
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondaryTextColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                }
            }
            
            // 最近の健康記録
            if !viewModel.recentHealthRecords.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("最近の健康記録")
                                .font(.headline)
                                .foregroundColor(.primaryTextColor)
                            
                            Spacer()
                            
                            NavigationLink(destination: HealthRecordListView(pet: viewModel.pet)) {
                                Text("すべて見る")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryColor)
                            }
                        }
                        
                        Divider()
                        
                        ForEach(viewModel.recentHealthRecords.prefix(3)) { record in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.relativeDateText)
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryTextColor)
                                    
                                    Text(record.summaryText)
                                        .font(.body)
                                        .foregroundColor(.primaryTextColor)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: record.healthStatus.icon)
                                    .foregroundColor(record.healthStatus.color)
                            }
                            .padding(.vertical, 4)
                            
                            if record.id != viewModel.recentHealthRecords.prefix(3).last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // 体重グラフ
            if viewModel.weightChartData.count > 1 {
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("体重の推移")
                            .font(.headline)
                            .foregroundColor(.primaryTextColor)
                        
                        Chart {
                            ForEach(viewModel.weightChartData, id: \.date) { item in
                                LineMark(
                                    x: .value("日付", item.date),
                                    y: .value("体重", item.weight)
                                )
                                .foregroundStyle(Color.primaryColor)
                                
                                PointMark(
                                    x: .value("日付", item.date),
                                    y: .value("体重", item.weight)
                                )
                                .foregroundStyle(Color.primaryColor)
                                .symbolSize(30)
                            }
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let date = value.as(Date.self) {
                                        Text(DateUtils.monthDayFormatter.string(from: date))
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let weight = value.as(Double.self) {
                                        Text("\(String(format: "%.1f", weight)) kg")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - 健康記録タブ
    private var healthRecordsTab: some View {
        VStack(spacing: 16) {
            // アクションボタン
            HStack {
                Spacer()
                
                Button(action: {
                    showAddHealthRecordSheet = true
                }) {
                    Label("健康記録を追加", systemImage: "plus")
                        .font(.body)
                        .foregroundColor(.primaryColor)
                }
                .buttonStyle(BorderedButtonStyle())
            }
            
            if viewModel.healthRecords.isEmpty {
                // 記録がない場合
                CardView {
                    EmptyStateView(
                        title: "健康記録がありません",
                        message: "健康記録を追加して、\(viewModel.pet.name)の健康状態を管理しましょう。",
                        iconName: "heart.text.square",
                        buttonTitle: "健康記録を追加",
                        action: {
                            showAddHealthRecordSheet = true
                        }
                    )
                    .padding()
                }
            } else {
                // 記録一覧
                ForEach(viewModel.healthRecords) { record in
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
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteHealthRecord(id: record.id)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - ワクチンタブ
    private var vaccinationsTab: some View {
        VStack(spacing: 16) {
            // アクションボタン
            HStack {
                Spacer()
                
                Button(action: {
                    showAddVaccinationSheet = true
                }) {
                    Label("ワクチン記録を追加", systemImage: "plus")
                        .font(.body)
                        .foregroundColor(.primaryColor)
                }
                .buttonStyle(BorderedButtonStyle())
            }
            
            if viewModel.vaccinations.isEmpty {
                // 記録がない場合
                CardView {
                    EmptyStateView(
                        title: "ワクチン記録がありません",
                        message: "ワクチン接種の記録を追加して、\(viewModel.pet.name)の健康管理をしましょう。",
                        iconName: "syringe",
                        buttonTitle: "ワクチン記録を追加",
                        action: {
                            showAddVaccinationSheet = true
                        }
                    )
                    .padding()
                }
            } else {
                // 注意が必要なワクチン
                if !viewModel.expiringVaccinations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("注意が必要なワクチン")
                            .font(.headline)
                            .foregroundColor(.primaryTextColor)
                        
                        ForEach(viewModel.expiringVaccinations) { vaccination in
                            CardView(backgroundColor: Color.warningColor.opacity(0.1)) {
                                vaccinationItem(vaccination)
                            }
                        }
                    }
                }
                
                // 次回接種予定
                if !viewModel.upcomingVaccinations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("次回接種予定")
                            .font(.headline)
                            .foregroundColor(.primaryTextColor)
                        
                        ForEach(viewModel.upcomingVaccinations) { vaccination in
                            CardView {
                                vaccinationItem(vaccination)
                            }
                        }
                    }
                }
                
                // それ以外のワクチン
                let otherVaccinations = viewModel.vaccinations.filter { vaccination in
                    !viewModel.expiringVaccinations.contains { $0.id == vaccination.id } &&
                    !viewModel.upcomingVaccinations.contains { $0.id == vaccination.id }
                }
                
                if !otherVaccinations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("その他のワクチン履歴")
                            .font(.headline)
                            .foregroundColor(.primaryTextColor)
                        
                        ForEach(otherVaccinations) { vaccination in
                            CardView {
                                vaccinationItem(vaccination)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ワクチンアイテムの共通表示
    private func vaccinationItem(_ vaccination: VaccinationModel) -> some View {
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
            
            // 接種場所
            if let clinicName = vaccination.clinicName {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("接種場所")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                        
                        Text(clinicName)
                            .font(.body)
                            .foregroundColor(.primaryTextColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let vetName = vaccination.vetName {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("獣医師")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                            
                            Text(vetName)
                                .font(.body)
                                .foregroundColor(.primaryTextColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            // メモ
            if let notes = vaccination.notes, !notes.isEmpty {
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
        .swipeActions {
            Button(role: .destructive) {
                viewModel.deleteVaccination(id: vaccination.id)
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }
}

// MARK: - プレビュー
struct PetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PetDetailView(pet: PetModel.sampleData[0])
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AppState())
        }
    }
}
