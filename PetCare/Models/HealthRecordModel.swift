// PetCare/Models/HealthRecordModel.swift

import Foundation
import SwiftUI

struct HealthRecordModel: Identifiable {
    let id: UUID
    var date: Date
    var weight: Double?
    var temperature: Double?
    var symptoms: String?
    var medications: String?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    var petId: UUID?  // 関連するペットのID
    
    // コアデータ Entity から Model へ変換するイニシャライザ
    init(entity: HealthRecord) {
        self.id = entity.id ?? UUID()
        self.date = entity.date ?? Date()
        self.weight = entity.weight
        self.temperature = entity.temperature
        self.symptoms = entity.symptoms
        self.medications = entity.medications
        self.notes = entity.notes
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
        self.petId = entity.pet?.id
    }
    
    // モックデータ作成用イニシャライザ
    init(id: UUID = UUID(), date: Date, weight: Double? = nil, temperature: Double? = nil,
         symptoms: String? = nil, medications: String? = nil, notes: String? = nil, petId: UUID? = nil) {
        self.id = id
        self.date = date
        self.weight = weight
        self.temperature = temperature
        self.symptoms = symptoms
        self.medications = medications
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
        self.petId = petId
    }
    
    // 日付の表示用文字列
    var dateText: String {
        return DateUtils.dateFormatter.string(from: date)
    }
    
    // 相対的な日付表現
    var relativeDateText: String {
        return DateUtils.relativeDate(from: date)
    }
    
    // フォーマットされた体重の文字列を返す
    var weightText: String? {
        guard let weight = weight else {
            return nil
        }
        return String(format: "%.1f kg", weight)
    }
    
    // フォーマットされた体温の文字列を返す
    var temperatureText: String? {
        guard let temperature = temperature else {
            return nil
        }
        return String(format: "%.1f °C", temperature)
    }
    
    // 症状があるかどうか
    var hasSymptoms: Bool {
        return symptoms != nil && !symptoms!.isEmpty
    }
    
    // 投薬があるかどうか
    var hasMedications: Bool {
        return medications != nil && !medications!.isEmpty
    }
    
    // 正常な体温範囲内かどうか（犬の場合を想定）
    var isTemperatureNormal: Bool? {
        guard let temperature = temperature else {
            return nil
        }
        return temperature >= 38.0 && temperature <= 39.2
    }
    
    // 健康記録の要約テキスト
    var summaryText: String {
        var summary = [String]()
        
        if let weightText = weightText {
            summary.append("体重: \(weightText)")
        }
        
        if let temperatureText = temperatureText {
            summary.append("体温: \(temperatureText)")
        }
        
        if hasSymptoms {
            summary.append("症状あり")
        }
        
        if hasMedications {
            summary.append("投薬あり")
        }
        
        return summary.isEmpty ? "記録のみ" : summary.joined(separator: ", ")
    }
    
    // 健康状態に基づくステータスタイプ
    enum HealthStatus {
        case good
        case warning
        case alert
        case unknown
        
        var color: Color {
            switch self {
            case .good:
                return .successColor
            case .warning:
                return .warningColor
            case .alert:
                return .errorColor
            case .unknown:
                return .infoColor
            }
        }
        
        var icon: String {
            switch self {
            case .good:
                return "checkmark.circle.fill"
            case .warning:
                return "exclamationmark.triangle.fill"
            case .alert:
                return "xmark.circle.fill"
            case .unknown:
                return "questionmark.circle.fill"
            }
        }
    }
    
    // 健康状態を判定
    var healthStatus: HealthStatus {
        // 症状がある場合は警告
        if hasSymptoms {
            return .warning
        }
        
        // 体温が正常範囲外の場合はアラート
        if let isNormal = isTemperatureNormal, !isNormal {
            return .alert
        }
        
        // 体重と体温のどちらかが記録されているかつ問題ない場合は良好
        if weight != nil || temperature != nil {
            return .good
        }
        
        // その他の場合は不明
        return .unknown
    }
}

// MARK: - サンプルデータ
extension HealthRecordModel {
    static var sampleData: [HealthRecordModel] {
        [
            HealthRecordModel(
                date: Date(),
                weight: 8.5,
                temperature: 38.5,
                notes: "元気です。"
            ),
            HealthRecordModel(
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                weight: 8.3,
                temperature: 38.7,
                symptoms: "少し食欲がない",
                medications: "ビタミン剤",
                notes: "様子を見る"
            ),
            HealthRecordModel(
                date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                weight: 8.2,
                temperature: 39.2,
                notes: "定期健診"
            )
        ]
    }
}
