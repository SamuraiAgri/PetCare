// PetCare/Models/VaccinationModel.swift

import Foundation
import SwiftUI

struct VaccinationModel: Identifiable {
    let id: UUID
    var name: String
    var date: Date
    var expiryDate: Date?
    var vetName: String?
    var clinicName: String?
    var notes: String?
    var nextDueDate: Date?
    var createdAt: Date
    var updatedAt: Date
    var petId: UUID?  // 関連するペットのID
    
    // コアデータ Entity から Model へ変換するイニシャライザ
    init(entity: Vaccination) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.date = entity.date ?? Date()
        self.expiryDate = entity.expiryDate
        self.vetName = entity.vetName
        self.clinicName = entity.clinicName
        self.notes = entity.notes
        self.nextDueDate = entity.nextDueDate
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
        self.petId = entity.pet?.id
    }
    
    // モックデータ作成用イニシャライザ
    init(id: UUID = UUID(), name: String, date: Date, expiryDate: Date? = nil,
         vetName: String? = nil, clinicName: String? = nil, notes: String? = nil,
         nextDueDate: Date? = nil, petId: UUID? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.expiryDate = expiryDate
        self.vetName = vetName
        self.clinicName = clinicName
        self.notes = notes
        self.nextDueDate = nextDueDate
        self.createdAt = Date()
        self.updatedAt = Date()
        self.petId = petId
    }
    
    // 接種日の表示用文字列
    var dateText: String {
        return DateUtils.dateFormatter.string(from: date)
    }
    
    // 有効期限の表示用文字列
    var expiryDateText: String? {
        guard let expiryDate = expiryDate else {
            return nil
        }
        return DateUtils.dateFormatter.string(from: expiryDate)
    }
    
    // 次回接種予定日の表示用文字列
    var nextDueDateText: String? {
        guard let nextDueDate = nextDueDate else {
            return nil
        }
        return DateUtils.dateFormatter.string(from: nextDueDate)
    }
    
    // 有効期限までの残り日数
    var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else {
            return nil
        }
        return DateUtils.daysRemaining(until: expiryDate)
    }
    
    // 次回接種までの残り日数
    var daysUntilNextDue: Int? {
        guard let nextDueDate = nextDueDate else {
            return nil
        }
        return DateUtils.daysRemaining(until: nextDueDate)
    }
    
    // 有効期限切れかどうか
    var isExpired: Bool {
        guard let expiryDate = expiryDate else {
            return false
        }
        return expiryDate < Date()
    }
    
    // 有効期限が近いかどうか（30日以内）
    var isExpiryNear: Bool {
        guard let days = daysUntilExpiry else {
            return false
        }
        return days >= 0 && days <= 30
    }
    
    // 次回接種が近いかどうか（14日以内）
    var isNextDueNear: Bool {
        guard let days = daysUntilNextDue else {
            return false
        }
        return days >= 0 && days <= 14
    }
    
    // 状態に応じたステータスタイプ
    enum VaccinationStatus {
        case valid       // 有効
        case nearExpiry  // 有効期限が近い
        case expired     // 有効期限切れ
        case dueSoon     // 次回接種が近い
        case unknown     // 不明/有効期限なし
        
        var color: Color {
            switch self {
            case .valid:
                return .successColor
            case .nearExpiry, .dueSoon:
                return .warningColor
            case .expired:
                return .errorColor
            case .unknown:
                return .infoColor
            }
        }
        
        var icon: String {
            switch self {
            case .valid:
                return "checkmark.circle.fill"
            case .nearExpiry, .dueSoon:
                return "exclamationmark.triangle.fill"
            case .expired:
                return "xmark.circle.fill"
            case .unknown:
                return "questionmark.circle.fill"
            }
        }
        
        var label: String {
            switch self {
            case .valid:
                return "有効"
            case .nearExpiry:
                return "期限近し"
            case .expired:
                return "期限切れ"
            case .dueSoon:
                return "接種予定"
            case .unknown:
                return "不明"
            }
        }
    }
    
    // 現在の状態を判定
    var status: VaccinationStatus {
        if isExpired {
            return .expired
        } else if isExpiryNear {
            return .nearExpiry
        } else if isNextDueNear {
            return .dueSoon
        } else if expiryDate != nil {
            return .valid
        } else {
            return .unknown
        }
    }
    
    // 状態に関する説明テキスト
    var statusDescription: String {
        switch status {
        case .valid:
            if let days = daysUntilExpiry {
                return "有効期限まであと\(days)日"
            }
            return "有効"
        case .nearExpiry:
            if let days = daysUntilExpiry {
                return "有効期限まであと\(days)日です"
            }
            return "有効期限が近づいています"
        case .expired:
            return "有効期限が切れています"
        case .dueSoon:
            if let days = daysUntilNextDue {
                return "次回接種まであと\(days)日です"
            }
            return "もうすぐ接種予定です"
        case .unknown:
            return "有効期限が設定されていません"
        }
    }
}

// MARK: - サンプルデータ
extension VaccinationModel {
    static var sampleData: [VaccinationModel] {
        [
            VaccinationModel(
                name: "混合ワクチン",
                date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Calendar.current.date(byAdding: .month, value: -3, to: Date())!)!,
                vetName: "鈴木先生",
                clinicName: "やまと動物病院",
                nextDueDate: Calendar.current.date(byAdding: .month, value: 9, to: Date())
            ),
            VaccinationModel(
                name: "狂犬病ワクチン",
                date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Calendar.current.date(byAdding: .month, value: -1, to: Date())!)!,
                vetName: "佐藤先生",
                clinicName: "むらた動物病院"
            ),
            VaccinationModel(
                name: "フィラリア予防",
                date: Calendar.current.date(byAdding: .day, value: -15, to: Date())!,
                expiryDate: Calendar.current.date(byAdding: .month, value: 1, to: Calendar.current.date(byAdding: .day, value: -15, to: Date())!)!,
                vetName: "鈴木先生",
                clinicName: "やまと動物病院",
                nextDueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())
            )
        ]
    }
}
