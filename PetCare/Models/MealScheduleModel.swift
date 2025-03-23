// PetCare/Models/MealScheduleModel.swift

import Foundation
import SwiftUI

struct MealScheduleModel: Identifiable {
    let id: UUID
    var name: String
    var time: Date
    var amount: Double
    var foodType: String
    var isActive: Bool
    var notes: String?
    var daysOfWeek: String? // カンマ区切りの曜日（"1,2,3,4,5,6,7"）
    var createdAt: Date
    var updatedAt: Date
    var petId: UUID?  // 関連するペットのID
    var foodSupplyId: UUID?  // 関連する食品在庫のID
    
    // コアデータ Entity から Model へ変換するイニシャライザ
    init(entity: MealSchedule) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.time = entity.time ?? Date()
        self.amount = entity.amount
        self.foodType = entity.foodType ?? ""
        self.isActive = entity.isActive
        self.notes = entity.notes
        self.daysOfWeek = entity.daysOfWeek
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
        self.petId = entity.pet?.id
        self.foodSupplyId = entity.foodSupply?.id
    }
    
    // モックデータ作成用イニシャライザ
    init(id: UUID = UUID(), name: String, time: Date, amount: Double, foodType: String,
         isActive: Bool = true, notes: String? = nil, daysOfWeek: String? = "1,2,3,4,5,6,7",
         petId: UUID? = nil, foodSupplyId: UUID? = nil) {
        self.id = id
        self.name = name
        self.time = time
        self.amount = amount
        self.foodType = foodType
        self.isActive = isActive
        self.notes = notes
        self.daysOfWeek = daysOfWeek
        self.createdAt = Date()
        self.updatedAt = Date()
        self.petId = petId
        self.foodSupplyId = foodSupplyId
    }
    
    // 時間のフォーマット（時分）
    var timeText: String {
        return DateUtils.timeFormatter.string(from: time)
    }
    
    // 給餌量のテキスト表現
    var amountText: String {
        return String(format: "%.0f g", amount)
    }
    
    // 曜日配列への変換
    var weekdaysArray: [Int] {
        guard let daysOfWeek = daysOfWeek else {
            return []
        }
        
        return daysOfWeek.split(separator: ",")
            .compactMap { Int($0) }
            .filter { $0 >= 1 && $0 <= 7 }
    }
    
    // 曜日の表示用テキスト
    var weekdaysText: String {
        let weekdays = weekdaysArray
        
        if weekdays.count == 7 {
            return "毎日"
        }
        
        if weekdays.contains(1) && weekdays.contains(7) && weekdays.count == 2 {
            return "週末"
        }
        
        if weekdays.contains(2) && weekdays.contains(3) && weekdays.contains(4) &&
           weekdays.contains(5) && weekdays.contains(6) && weekdays.count == 5 {
            return "平日"
        }
        
        let dayNames = ["日", "月", "火", "水", "木", "金", "土", "日"]
        let dayTexts = weekdays.map { dayNames[$0] }
        return dayTexts.joined(separator: "・") + "曜日"
    }
    
    // 特定の曜日が含まれているかどうか
    func containsWeekday(_ weekday: Int) -> Bool {
        return weekdaysArray.contains(weekday)
    }
    
    // 今日の食事かどうか
    var isToday: Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return containsWeekday(weekday)
    }
    
    // 現在時刻から見て次回の食事時間
    var nextMealTime: Date? {
        guard isActive else {
            return nil
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // 現在の時間コンポーネント（時・分のみ）
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        // 食事の時間コンポーネント（時・分のみ）
        let mealHour = calendar.component(.hour, from: time)
        let mealMinute = calendar.component(.minute, from: time)
        
        // 今日の日付で食事時間を作成
        var components = DateComponents()
        components.year = calendar.component(.year, from: now)
        components.month = calendar.component(.month, from: now)
        components.day = calendar.component(.day, from: now)
        components.hour = mealHour
        components.minute = mealMinute
        
        guard let todayMealTime = calendar.date(from: components) else {
            return nil
        }
        
        // 今日の食事時間がまだ来ていなければそれを返す
        if todayMealTime > now {
            return todayMealTime
        }
        
        // 今日の曜日を取得
        let currentWeekday = calendar.component(.weekday, from: now)
        
        // 有効な曜日をソート
        let sortedWeekdays = weekdaysArray.sorted()
        
        // 次の有効な曜日を探す
        var nextWeekday: Int? = nil
        for day in sortedWeekdays {
            if day > currentWeekday {
                nextWeekday = day
                break
            }
        }
        
        // 次の曜日が見つからない場合は次の週の最初の有効な曜日
        if nextWeekday == nil, let firstDay = sortedWeekdays.first {
            nextWeekday = firstDay
            // 日付を次の週に設定
            components.day = calendar.component(.day, from: now) + (7 - currentWeekday + firstDay)
        } else if let nextDay = nextWeekday {
            // 日付を次の有効な曜日に設定
            components.day = calendar.component(.day, from: now) + (nextDay - currentWeekday)
        } else {
            return nil
        }
        
        return calendar.date(from: components)
    }
    
    // 次回の食事までの時間（分）
    var minutesUntilNextMeal: Int? {
        guard let nextMealTime = nextMealTime else {
            return nil
        }
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: now, to: nextMealTime)
        return components.minute
    }
    
    // 次回の食事までの時間を文字列で表現
    var timeUntilNextMealText: String? {
        guard let minutes = minutesUntilNextMeal else {
            return nil
        }
        
        if minutes < 60 {
            return "\(minutes)分後"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)時間後"
            } else {
                return "\(hours)時間\(remainingMinutes)分後"
            }
        }
    }
    
    // 食事の状態
    enum MealStatus {
        case upcoming
        case soon
        case past
        case inactive
        
        var color: Color {
            switch self {
            case .upcoming:
                return .infoColor
            case .soon:
                return .warningColor
            case .past:
                return .tertiaryTextColor
            case .inactive:
                return .errorColor
            }
        }
        
        var icon: String {
            switch self {
            case .upcoming:
                return "clock"
            case .soon:
                return "exclamationmark.circle.fill"
            case .past:
                return "checkmark.circle.fill"
            case .inactive:
                return "xmark.circle.fill"
            }
        }
    }
    
    // 食事の状態を判定
    var status: MealStatus {
        if !isActive {
            return .inactive
        }
        
        guard let minutes = minutesUntilNextMeal else {
            return .past
        }
        
        if minutes <= 30 {
            return .soon
        } else {
            return .upcoming
        }
    }
}

// MARK: - サンプルデータ
extension MealScheduleModel {
    static var sampleData: [MealScheduleModel] {
        [
            MealScheduleModel(
                name: "朝食",
                time: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date())!,
                amount: 150,
                foodType: "ドライフード",
                daysOfWeek: "1,2,3,4,5,6,7"
            ),
            MealScheduleModel(
                name: "夕食",
                time: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
                amount: 150,
                foodType: "ドライフード",
                daysOfWeek: "1,2,3,4,5,6,7"
            ),
            MealScheduleModel(
                name: "おやつ",
                time: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!,
                amount: 30,
                foodType: "ジャーキー",
                isActive: true,
                daysOfWeek: "1,7"
            )
        ]
    }
}
