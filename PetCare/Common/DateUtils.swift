// PetCare/Common/DateUtils.swift

import Foundation

struct DateUtils {
    // 日付のみを表示 (例: 2023/04/12)
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    // 時間のみを表示 (例: 14:30)
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // 日付と時間を表示 (例: 2023/04/12 14:30)
    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
    // 月と日を表示 (例: 4月12日)
    static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    // 曜日付きで日付を表示 (例: 4月12日(水))
    static let dateWithWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    // 相対的な日付表現 (例: 今日、昨日、3日前)
    static func relativeDate(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now))
        
        if let day = components.day {
            if day == 0 {
                return "今日"
            } else if day == 1 {
                return "昨日"
            } else if day <= 7 {
                return "\(day)日前"
            }
        }
        
        return dateFormatter.string(from: date)
    }
    
    // 年齢計算 (誕生日から現在までの年数)
    static func calculateAge(birthdate: Date) -> String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year, .month], from: birthdate, to: Date())
        
        if let year = ageComponents.year, let month = ageComponents.month {
            if year == 0 {
                return "\(month)ヶ月"
            } else {
                return "\(year)歳\(month)ヶ月"
            }
        }
        
        return "不明"
    }
    
    // 指定された日時が過去かどうかをチェック
    static func isPast(_ date: Date) -> Bool {
        return date < Date()
    }
    
    // 指定された日時が今日かどうかをチェック
    static func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    // 指定された日時が今週かどうかをチェック
    static func isThisWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday + 5) % 7 // 月曜日を週の始まりとする
        
        guard let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today),
              let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday) else {
            return false
        }
        
        return date >= monday && date < nextMonday
    }
    
    // 日付の差を日数で返す
    static func daysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end))
        return components.day ?? 0
    }
    
    // 指定された日時までの残り日数を返す
    static func daysRemaining(until date: Date) -> Int {
        return daysBetween(start: Date(), end: date)
    }
    
    // 指定された時間を「XX分前」「XX時間前」などの形式で返す
    static func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return year == 1 ? "1年前" : "\(year)年前"
        }
        
        if let month = components.month, month > 0 {
            return month == 1 ? "1ヶ月前" : "\(month)ヶ月前"
        }
        
        if let day = components.day, day > 0 {
            return day == 1 ? "1日前" : "\(day)日前"
        }
        
        if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1時間前" : "\(hour)時間前"
        }
        
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1分前" : "\(minute)分前"
        }
        
        return "たった今"
    }
}
