// PetCare/Models/AppointmentModel.swift

import Foundation
import SwiftUI

struct AppointmentModel: Identifiable {
    let id: UUID
    var title: String
    var type: String  // "vet", "grooming", "other"
    var date: Date
    var time: Date
    var duration: Int?  // 分単位
    var location: String?
    var notes: String?
    var isDone: Bool
    var reminderTime: Int?  // 分単位（何分前に通知するか）
    var createdAt: Date
    var updatedAt: Date
    var petId: UUID?  // 関連するペットのID
    
    // コアデータ Entity から Model へ変換するイニシャライザ
    init(entity: Appointment) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.type = entity.type ?? "other"
        self.date = entity.date ?? Date()
        self.time = entity.time ?? Date()
        self.duration = Int(entity.duration)
        self.location = entity.location
        self.notes = entity.notes
        self.isDone = entity.isDone
        self.reminderTime = Int(entity.reminderTime)
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
        self.petId = entity.pet?.id
    }
    
    // モックデータ作成用イニシャライザ
    init(id: UUID = UUID(), title: String, type: String, date: Date, time: Date,
         duration: Int? = nil, location: String? = nil, notes: String? = nil,
         isDone: Bool = false, reminderTime: Int? = nil, petId: UUID? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.date = date
        self.time = time
        self.duration = duration
        self.location = location
        self.notes = notes
        self.isDone = isDone
        self.reminderTime = reminderTime
        self.createdAt = Date()
        self.updatedAt = Date()
        self.petId = petId
    }
    
    // 日付のフォーマット（年月日）
    var dateText: String {
        return DateUtils.dateFormatter.string(from: date)
    }
    
    // 時間のフォーマット（時分）
    var timeText: String {
        return DateUtils.timeFormatter.string(from: time)
    }
    
    // 日時のフォーマット（年月日 時分）
    var dateTimeText: String {
        return DateUtils.dateTimeFormatter.string(from: time)
    }
    
    // 曜日付きの日付表示（例: 4月12日(水)）
    var dateWithWeekdayText: String {
        return DateUtils.dateWithWeekdayFormatter.string(from: date)
    }
    
    // 終了時間の計算
    var endTime: Date? {
        guard let duration = duration else {
            return nil
        }
        return Calendar.current.date(byAdding: .minute, value: duration, to: time)
    }
    
    // 終了時間のテキスト表現
    var endTimeText: String? {
        guard let endTime = endTime else {
            return nil
        }
        return DateUtils.timeFormatter.string(from: endTime)
    }
    
    // 予約タイプに基づく表示アイコン名を返す
    var iconName: String {
        switch type.lowercased() {
        case "vet":
            return "stethoscope"
        case "grooming":
            return "scissors"
        default:
            return "calendar"
        }
    }
    
    // 予約タイプに基づく色を返す
    var typeColor: Color {
        switch type.lowercased() {
        case "vet":
            return .primaryColor
        case "grooming":
            return .secondaryColor
        default:
            return .accentColor
        }
    }
    
    // 予約タイプの日本語表記を返す
    var typeText: String {
        switch type.lowercased() {
        case "vet":
            return "獣医"
        case "grooming":
            return "トリミング"
        default:
            return "その他"
        }
    }
    
    // 予約が今日かどうか
    var isToday: Bool {
        return DateUtils.isToday(date)
    }
    
    // 予約が過去かどうか
    var isPast: Bool {
        return DateUtils.isPast(date)
    }
    
    // 予約が近いかどうか（7日以内）
    var isUpcoming: Bool {
        let days = DateUtils.daysRemaining(until: date)
        return days >= 0 && days <= 7
    }
    
    // 予約の状態に基づくステータスタイプ
    enum AppointmentStatus {
        case upcoming
        case today
        case past
        case completed
        
        var color: Color {
            switch self {
            case .upcoming:
                return .infoColor
            case .today:
                return .warningColor
            case .past:
                return .errorColor
            case .completed:
                return .successColor
            }
        }
        
        var icon: String {
            switch self {
            case .upcoming:
                return "calendar"
            case .today:
                return "exclamationmark.circle.fill"
            case .past:
                return "xmark.circle.fill"
            case .completed:
                return "checkmark.circle.fill"
            }
        }
        
        var label: String {
            switch self {
            case .upcoming:
                return "予定"
            case .today:
                return "今日"
            case .past:
                return "過去"
            case .completed:
                return "完了"
            }
        }
    }
    
    // 予約の状態を判定
    var status: AppointmentStatus {
        if isDone {
            return .completed
        } else if isToday {
            return .today
        } else if isPast {
            return .past
        } else {
            return .upcoming
        }
    }
}

// MARK: - サンプルデータ
extension AppointmentModel {
    static var sampleData: [AppointmentModel] {
        [
            AppointmentModel(
                title: "定期健康診断",
                type: "vet",
                date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                time: Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: Calendar.current.date(byAdding: .day, value: 5, to: Date())!)!,
                duration: 60,
                location: "やまと動物病院",
                notes: "予防接種も行います",
                reminderTime: 60
            ),
            AppointmentModel(
                title: "トリミング",
                type: "grooming",
                date: Date(),
                time: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!,
                duration: 90,
                location: "ペットサロンふわふわ",
                reminderTime: 120
            ),
            AppointmentModel(
                title: "しつけ教室",
                type: "other",
                date: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
                time: Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 10, to: Date())!)!,
                duration: 120,
                location: "ペットスクールわんわん",
                notes: "基本的な服従訓練",
                reminderTime: 60
            )
        ]
    }
}
