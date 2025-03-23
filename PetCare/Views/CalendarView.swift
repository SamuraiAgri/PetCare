// PetCare/Views/CalendarView.swift

import SwiftUI
import CoreData

struct CalendarView: View {
    // 環境変数
    @Environment(\.managedObjectContext) private var viewContext
    
    // 環境オブジェクト
    @EnvironmentObject var appState: AppState
    
    // 状態変数
    @State private var selectedDate = Date()
    @State private var showAddAppointmentSheet = false
    @State private var appointments: [AppointmentModel] = []
    @State private var isLoading = false
    @State private var calendarMonthOffset = 0  // 現在月からのオフセット
    
    var body: some View {
        VStack(spacing: 0) {
            // カレンダーヘッダー
            calendarHeader
            
            // カレンダー表示
            customCalendarView
            
            Divider()
                .padding(.vertical, 8)
            
            // 選択した日の予定
            selectedDateEventsView
        }
        .background(Color.backgroundColor.ignoresSafeArea())
        .navigationTitle("スケジュール")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddAppointmentSheet = true
                }) {
                    Label("追加", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddAppointmentSheet) {
            AppointmentEntryView(date: selectedDate, onComplete: { _ in
                loadAppointments()
            })
        }
        .onAppear {
            loadAppointments()
        }
    }
    
    // カレンダーヘッダー
    private var calendarHeader: some View {
        HStack {
            // 前月ボタン
            Button(action: {
                calendarMonthOffset -= 1
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.primaryColor)
            }
            
            Spacer()
            
            // 表示中の年月
            Text(currentMonthTitle)
                .font(.headline)
            
            Spacer()
            
            // 翌月ボタン
            Button(action: {
                calendarMonthOffset += 1
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.primaryColor)
            }
            
            // 今日ボタン
            Button(action: {
                calendarMonthOffset = 0
                selectedDate = Date()
            }) {
                Text("今日")
                    .font(.subheadline)
                    .foregroundColor(.primaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.primaryColor.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // カスタムカレンダービュー
    private var customCalendarView: some View {
        VStack(spacing: 4) {
            // 曜日表示
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(.secondaryTextColor)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .background(Color.white)
            
            // 日付グリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(calendarDates, id: \.self) { date in
                    if let date = date {
                        calendarDateCell(date: date)
                    } else {
                        // 空のセル（前月または翌月の日）
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 50)
                    }
                }
            }
            .background(Color.white)
        }
    }
    
    // カレンダーの日付セル
    private func calendarDateCell(date: Date) -> some View {
        let isSelected = isSameDay(date1: date, date2: selectedDate)
        let isToday = isSameDay(date1: date, date2: Date())
        let dayString = String(Calendar.current.component(.day, from: date))
        let eventsForDate = eventsForDate(date)
        
        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                // 日付テキスト
                ZStack {
                    if isToday {
                        Circle()
                            .fill(isSelected ? Color.primaryColor : Color.primaryColor.opacity(0.3))
                            .frame(width: 32, height: 32)
                    } else if isSelected {
                        Circle()
                            .fill(Color.primaryColor)
                            .frame(width: 32, height: 32)
                    }
                    
                    Text(dayString)
                        .font(.body)
                        .foregroundColor(
                            (isSelected || isToday) ? .white : isCurrentMonth(date) ? .primaryTextColor : .tertiaryTextColor
                        )
                }
                
                // イベントドット
                HStack(spacing: 4) {
                    ForEach(eventTypes(for: eventsForDate).prefix(3), id: \.self) { type in
                        Circle()
                            .fill(eventTypeColor(type))
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .frame(height: 50)
        }
        .frame(maxWidth: .infinity)
    }
    
    // 選択した日の予定表示
    private var selectedDateEventsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 選択した日付の表示
                HStack {
                    Text(selectedDateTitle)
                        .font(.headline)
                        .foregroundColor(.primaryTextColor)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddAppointmentSheet = true
                    }) {
                        Label("予定を追加", systemImage: "plus")
                            .font(.subheadline)
                            .foregroundColor(.primaryColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // 選択した日の予定一覧
                let eventsForSelectedDate = eventsForDate(selectedDate)
                
                if eventsForSelectedDate.isEmpty {
                    // 予定がない場合
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.secondaryTextColor)
                        
                        Text("予定がありません")
                            .font(.body)
                            .foregroundColor(.secondaryTextColor)
                        
                        Button(action: {
                            showAddAppointmentSheet = true
                        }) {
                            Text("予定を追加")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.primaryColor)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // 予定の表示
                    ForEach(eventsForSelectedDate.sorted { $0.time < $1.time }) { appointment in
                        appointmentCard(appointment: appointment)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // アポイントメントカード
    private func appointmentCard(appointment: AppointmentModel) -> some View {
        CardView {
            HStack(spacing: 16) {
                // 時間表示
                VStack(alignment: .center, spacing: 4) {
                    Text(timeString(from: appointment.time))
                        .font(.headline)
                        .foregroundColor(.primaryTextColor)
                    
                    if let endTime = appointment.endTime {
                        Text("～\(timeString(from: endTime))")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                    }
                }
                .frame(width: 80)
                
                Rectangle()
                    .fill(appointment.typeColor)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                // 予約情報
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(appointment.title)
                            .font(.headline)
                            .foregroundColor(.primaryTextColor)
                        
                        Spacer()
                        
                        TagView(
                            text: appointment.typeText,
                            color: appointment.typeColor
                        )
                    }
                    
                    if let petId = appointment.petId, let pet = getPet(id: petId) {
                        HStack(spacing: 8) {
                            PetAvatarView(
                                imageData: pet.imageData,
                                name: pet.name,
                                size: 24,
                                petType: pet.type
                            )
                            
                            Text(pet.name)
                                .font(.subheadline)
                                .foregroundColor(.secondaryTextColor)
                        }
                    }
                    
                    if let location = appointment.location {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                            
                            Text(location)
                                .font(.subheadline)
                                .foregroundColor(.secondaryTextColor)
                        }
                    }
                    
                    if let notes = appointment.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .contextMenu {
            // 予定の完了/未完了切り替え
            Button(action: {
                toggleAppointmentCompletion(appointment)
            }) {
                if appointment.isDone {
                    Label("未完了にする", systemImage: "xmark.circle")
                } else {
                    Label("完了にする", systemImage: "checkmark.circle")
                }
            }
            
            // 削除
            Button(role: .destructive, action: {
                deleteAppointment(appointment)
            }) {
                Label("削除", systemImage: "trash")
            }
        }
    }
    
    // MARK: - ヘルパーメソッド
    
    // 現在表示中の月のタイトル（例: 2023年4月）
    private var currentMonthTitle: String {
        let calendar = Calendar.current
        let currentDate = calendar.date(byAdding: .month, value: calendarMonthOffset, to: Date()) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: currentDate)
    }
    
    // 選択された日付のタイトル（例: 2023年4月12日（水））
    private var selectedDateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }
    
    // 曜日シンボル
    private var weekdaySymbols: [String] {
        return ["日", "月", "火", "水", "木", "金", "土"]
    }
    
    // カレンダーに表示する日付の配列
    private var calendarDates: [Date?] {
        let calendar = Calendar.current
        let currentDate = calendar.date(byAdding: .month, value: calendarMonthOffset, to: Date()) ?? Date()
        
        // 現在の月の初日
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        // 月の初日の曜日（0:日曜、1:月曜、...）
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // 月の日数
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        
        // カレンダーに表示する日付の配列
        var dates: [Date?] = []
        
        // 前月の日を追加
        for _ in 0..<firstWeekday {
            dates.append(nil)
        }
        
        // 当月の日を追加
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                dates.append(date)
            }
        }
        
        // 6週間分（42日）になるまで翌月の日を追加
        while dates.count < 42 {
            dates.append(nil)
        }
        
        return dates
    }
    
    // 特定の日の予定を取得
    private func eventsForDate(_ date: Date) -> [AppointmentModel] {
        return appointments.filter { appointment in
            isSameDay(date1: appointment.date, date2: date)
        }
    }
    
    // 予定の種類（vet, grooming, other）を取得
    private func eventTypes(for events: [AppointmentModel]) -> [String] {
        return Array(Set(events.map { $0.type }))
    }
    
    // 予定の種類に対応する色を取得
    private func eventTypeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "vet":
            return .primaryColor
        case "grooming":
            return .secondaryColor
        default:
            return .accentColor
        }
    }
    
    // 時間の文字列表現（例: 14:30）
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // 同じ日かどうかを判定
    private func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // 現在表示中の月の日付かどうかを判定
    private func isCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = calendar.date(byAdding: .month, value: calendarMonthOffset, to: Date()) ?? Date()
        
        let year1 = calendar.component(.year, from: date)
        let month1 = calendar.component(.month, from: date)
        let year2 = calendar.component(.year, from: currentDate)
        let month2 = calendar.component(.month, from: currentDate)
        
        return year1 == year2 && month1 == month2
    }
    
    // 予約データを読み込み
    private func loadAppointments() {
        isLoading = true
        
        do {
            let request: NSFetchRequest<Appointment> = Appointment.fetchRequest()
            
            // 選択されたペットがある場合はそのペットの予約のみ表示
            if let selectedPetId = appState.selectedPetId {
                let petRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
                petRequest.predicate = NSPredicate(format: "id == %@", selectedPetId as CVarArg)
                
                if let pet = try viewContext.fetch(petRequest).first {
                    request.predicate = NSPredicate(format: "pet == %@", pet)
                }
            }
            
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Appointment.date, ascending: true),
                NSSortDescriptor(keyPath: \Appointment.time, ascending: true)
            ]
            
            let results = try viewContext.fetch(request)
            self.appointments = results.map { AppointmentModel(entity: $0) }
            
            isLoading = false
        } catch {
            print("予約データの取得エラー: \(error)")
            isLoading = false
        }
    }
    
    // ペットIDからペットモデルを取得
    private func getPet(id: UUID) -> PetModel? {
        do {
            let request: NSFetchRequest<Pet> = Pet.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            if let pet = try viewContext.fetch(request).first {
                return PetModel(entity: pet)
            }
        } catch {
            print("ペットデータの取得エラー: \(error)")
        }
        
        return nil
    }
    
    // 予約の完了/未完了を切り替え
    private func toggleAppointmentCompletion(_ appointment: AppointmentModel) {
        do {
            let request: NSFetchRequest<Appointment> = Appointment.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", appointment.id as CVarArg)
            request.fetchLimit = 1
            
            if let entity = try viewContext.fetch(request).first {
                entity.isDone = !entity.isDone
                entity.updatedAt = Date()
                
                try viewContext.save()
                loadAppointments()
            }
        } catch {
            print("予約の更新エラー: \(error)")
        }
    }
    
    // 予約を削除
    private func deleteAppointment(_ appointment: AppointmentModel) {
        do {
            let request: NSFetchRequest<Appointment> = Appointment.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", appointment.id as CVarArg)
            request.fetchLimit = 1
            
            if let entity = try viewContext.fetch(request).first {
                viewContext.delete(entity)
                try viewContext.save()
                loadAppointments()
            }
        } catch {
            print("予約の削除エラー: \(error)")
        }
    }
}

// MARK: - プレビュー
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CalendarView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AppState())
        }
    }
}
