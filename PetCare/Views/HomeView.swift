// PetCare/Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    // ビューモデル
    @StateObject private var viewModel = HomeViewModel()
    
    // 環境オブジェクト
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    
    // UI状態
    @State private var showAddPetSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ペット選択スクロールエリア
                if viewModel.hasPets {
                    petSelectorView
                } else {
                    emptyPetView
                }
                
                // リマインダーエリア
                reminderArea
                
                // アクションエリア
                actionCards
            }
            .padding()
        }
        .background(Color.backgroundColor.ignoresSafeArea())
        .navigationTitle("PetCare")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.hasPets {
                    Menu {
                        Button(action: {
                            showAddPetSheet = true
                        }) {
                            Label("ペットを追加", systemImage: "plus")
                        }
                        
                        Button(action: {
                            viewModel.loadHomeData()
                        }) {
                            Label("更新", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .refreshable {
            viewModel.loadHomeData()
        }
        .sheet(isPresented: $showAddPetSheet) {
            AddPetView { newPet in
                viewModel.loadHomeData()
                if let newPet = newPet {
                    viewModel.selectPet(newPet)
                    // アプリの状態も更新
                    appState.selectPet(newPet.id)
                }
            }
        }
        .onAppear {
            // 選択されているペットがあれば、それを選択状態にする
            if let selectedPetId = appState.selectedPetId,
               let selectedPet = viewModel.pets.first(where: { $0.id == selectedPetId }) {
                viewModel.selectPet(selectedPet)
            }
        }
        .onChange(of: viewModel.selectedPet) { pet in
            // 選択ペットが変更されたらアプリの状態も更新
            if let pet = pet {
                appState.selectPet(pet.id)
            } else {
                appState.selectPet(nil)
            }
        }
    }
    
    // MARK: - ペット選択UI
    private var petSelectorView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ペット選択")
                .font(.headline)
                .foregroundColor(.primaryTextColor)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.pets) { pet in
                        Button {
                            viewModel.selectPet(pet)
                        } label: {
                            VStack(spacing: 8) {
                                PetAvatarView(
                                    imageData: pet.imageData,
                                    name: pet.name,
                                    size: 60,
                                    petType: pet.type
                                )
                                
                                Text(pet.name)
                                    .font(.subheadline)
                                    .foregroundColor(
                                        viewModel.selectedPet?.id == pet.id ?
                                        pet.typeColor : .primaryTextColor
                                    )
                                    .lineLimit(1)
                            }
                            .frame(width: 80)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(
                                        color: Color.black.opacity(0.05),
                                        radius: 4, x: 0, y: 2
                                    )
                                    .opacity(viewModel.selectedPet?.id == pet.id ? 1 : 0)
                            )
                        }
                    }
                    
                    Button {
                        showAddPetSheet = true
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.backgroundColor)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.primaryColor)
                            }
                            
                            Text("追加")
                                .font(.subheadline)
                                .foregroundColor(.primaryColor)
                        }
                        .frame(width: 80)
                    }
                }
                .padding(.vertical, 5)
            }
            .padding(.horizontal, -16)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - ペットがない場合の表示
    private var emptyPetView: some View {
        CardView {
            EmptyStateView(
                title: "ペットがいません",
                message: "まずは、あなたのペットを登録しましょう。",
                iconName: "pawprint.circle",
                buttonTitle: "ペットを登録する",
                action: {
                    showAddPetSheet = true
                }
            )
        }
    }
    
    // MARK: - リマインダーエリア
    private var reminderArea: some View {
        VStack(spacing: 16) {
            if viewModel.hasPets {
                if viewModel.hasVaccinationAlerts {
                    vaccinationAlertsCard
                }
                
                if viewModel.hasTodayAppointments {
                    todayAppointmentsCard
                }
                
                if viewModel.hasTodayFeedings {
                    todayFeedingsCard
                }
                
                if !viewModel.hasTodayAppointments && !viewModel.hasVaccinationAlerts && !viewModel.hasTodayFeedings {
                    CardView {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.successColor)
                                .padding(.bottom, 4)
                            
                            Text("今日は特に予定がありません")
                                .font(.headline)
                                .foregroundColor(.primaryTextColor)
                                .multilineTextAlignment(.center)
                            
                            Text("すべてのスケジュールは「スケジュール」タブで確認できます")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
            }
        }
    }
    
    // MARK: - ワクチンアラートカード
    private var vaccinationAlertsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "syringe")
                        .font(.headline)
                        .foregroundColor(.warningColor)
                    
                    Text("ワクチン接種の注意")
                        .font(.headline)
                        .foregroundColor(.primaryTextColor)
                    
                    Spacer()
                    
                    Text("\(viewModel.vaccinationAlerts.count)件")
                        .font(.caption)
                        .foregroundColor(.secondaryTextColor)
                }
                
                Divider()
                
                ForEach(viewModel.vaccinationAlerts.prefix(3), id: \.vaccination.id) { alert in
                    HStack(spacing: 12) {
                        if viewModel.petCount > 1 {
                            PetAvatarView(
                                imageData: alert.pet.imageData,
                                name: alert.pet.name,
                                size: 36,
                                petType: alert.pet.type
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(alert.vaccination.name)
                                    .font(.subheadline)
                                    .foregroundColor(.primaryTextColor)
                                
                                if viewModel.petCount == 1 {
                                    Spacer()
                                    
                                    TagView(
                                        text: alert.vaccination.status.label,
                                        color: alert.vaccination.status.color
                                    )
                                }
                            }
                            
                            Text(alert.vaccination.statusDescription)
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                        }
                        
                        if viewModel.petCount > 1 {
                            Spacer()
                            
                            TagView(
                                text: alert.vaccination.status.label,
                                color: alert.vaccination.status.color
                            )
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if alert.vaccination.id != viewModel.vaccinationAlerts.prefix(3).last?.vaccination.id {
                        Divider()
                    }
                }
                
                if viewModel.vaccinationAlerts.count > 3 {
                    Button(action: {
                        // ワクチン一覧へ遷移
                    }) {
                        Text("すべて表示")
                            .font(.footnote)
                            .foregroundColor(.primaryColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - 今日の予約カード
    private var todayAppointmentsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.headline)
                        .foregroundColor(.primaryColor)
                    
                    Text("今日の予定")
                        .font(.headline)
                        .foregroundColor(.primaryTextColor)
                    
                    Spacer()
                    
                    Text("\(viewModel.todayAppointments.count)件")
                        .font(.caption)
                        .foregroundColor(.secondaryTextColor)
                }
                
                Divider()
                
                ForEach(viewModel.todayAppointments) { appointment in
                    HStack(spacing: 12) {
                        if viewModel.petCount > 1, let pet = viewModel.pets.first(where: { $0.id == appointment.petId }) {
                            PetAvatarView(
                                imageData: pet.imageData,
                                name: pet.name,
                                size: 36,
                                petType: pet.type
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appointment.title)
                                .font(.subheadline)
                                .foregroundColor(.primaryTextColor)
                            
                            HStack {
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondaryTextColor)
                                
                                Text(appointment.timeText)
                                    .font(.caption)
                                    .foregroundColor(.secondaryTextColor)
                                
                                if let location = appointment.location {
                                    Text("・")
                                        .font(.caption)
                                        .foregroundColor(.tertiaryTextColor)
                                    
                                    Text(location)
                                        .font(.caption)
                                        .foregroundColor(.secondaryTextColor)
                                        .lineLimit(1)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        TagView(
                            text: appointment.typeText,
                            color: appointment.typeColor
                        )
                    }
                    .padding(.vertical, 4)
                    
                    if appointment.id != viewModel.todayAppointments.last?.id {
                        Divider()
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - 今日の給餌スケジュールカード
    private var todayFeedingsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "bowl.fill")
                        .font(.headline)
                        .foregroundColor(.secondaryColor)
                    
                    Text("今日の給餌")
                        .font(.headline)
                        .foregroundColor(.primaryTextColor)
                    
                    Spacer()
                    
                    Text("\(viewModel.todayFeedings.count)件")
                        .font(.caption)
                        .foregroundColor(.secondaryTextColor)
                }
                
                Divider()
                
                ForEach(viewModel.todayFeedings.prefix(3), id: \.meal.id) { feeding in
                    HStack(spacing: 12) {
                        if viewModel.petCount > 1 {
                            PetAvatarView(
                                imageData: feeding.pet.imageData,
                                name: feeding.pet.name,
                                size: 36,
                                petType: feeding.pet.type
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(feeding.meal.name)
                                    .font(.subheadline)
                                    .foregroundColor(.primaryTextColor)
                                
                                if viewModel.petCount == 1 {
                                    Spacer()
                                    
                                    Text(feeding.meal.timeText)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.secondaryColor.opacity(0.2))
                                        .foregroundColor(.secondaryColor)
                                        .cornerRadius(10)
                                }
                            }
                            
                            HStack {
                                Text("\(feeding.meal.foodType) ・ \(feeding.meal.amountText)")
                                    .font(.caption)
                                    .foregroundColor(.secondaryTextColor)
                                
                                if let timeUntil = feeding.meal.timeUntilNextMealText {
                                    Text("・ \(timeUntil)")
                                        .font(.caption)
                                        .foregroundColor(
                                            feeding.meal.status == .soon ? .warningColor : .secondaryTextColor
                                        )
                                }
                            }
                        }
                        
                        if viewModel.petCount > 1 {
                            Spacer()
                            
                            Text(feeding.meal.timeText)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.secondaryColor.opacity(0.2))
                                .foregroundColor(.secondaryColor)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if feeding.meal.id != viewModel.todayFeedings.prefix(3).last?.meal.id {
                        Divider()
                    }
                }
                
                if viewModel.todayFeedings.count > 3 {
                    Button(action: {
                        // 給餌スケジュール一覧へ遷移
                    }) {
                        Text("すべて表示")
                            .font(.footnote)
                            .foregroundColor(.primaryColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - アクションカード
    private var actionCards: some View {
        VStack(spacing: 16) {
            if viewModel.hasPets {
                HStack(spacing: 16) {
                    NavigationLink(destination: HealthRecordEntryView(pet: viewModel.selectedPet)) {
                        actionCard(
                            title: "健康記録",
                            icon: "heart.fill",
                            color: .errorColor
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: MealScheduleView(pet: viewModel.selectedPet)) {
                        actionCard(
                            title: "給餌管理",
                            icon: "bowl.fill",
                            color: .secondaryColor
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack(spacing: 16) {
                    NavigationLink(destination: AppointmentEntryView(pet: viewModel.selectedPet, onComplete: { _ in
                        // 予定が追加された後の処理
                        viewModel.loadHomeData()
                    })) {
                        actionCard(
                            title: "予約登録",
                            icon: "calendar.badge.plus",
                            color: .primaryColor
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: VaccinationEntryView(pet: viewModel.selectedPet)) {
                        actionCard(
                            title: "ワクチン記録",
                            icon: "syringe",
                            color: .warningColor
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - アクションカードのコンポーネント
    private func actionCard(title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - プレビュー
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AppState())
        }
    }
}
