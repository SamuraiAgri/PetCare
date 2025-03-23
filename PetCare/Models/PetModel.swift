// PetCare/Models/PetModel.swift
import Foundation
import SwiftUI

struct PetModel: Identifiable, Equatable {
    let id: UUID
    var name: String
    var type: String
    var breed: String?
    var birthday: Date?
    var gender: String?
    var weight: Double?
    var imageData: Data?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Equatableの実装 - IDのみで等価性を判断
    static func == (lhs: PetModel, rhs: PetModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 以下は既存のコードと同じ
    // コアデータ Entity から Model へ変換するイニシャライザ
    init(entity: Pet) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.type = entity.type ?? ""
        self.breed = entity.breed
        self.birthday = entity.birthday
        self.gender = entity.gender
        self.weight = entity.weight
        self.imageData = entity.imageData
        self.notes = entity.notes
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
    }
    
    // モックデータ作成用イニシャライザ
    init(id: UUID = UUID(), name: String, type: String, breed: String? = nil,
         birthday: Date? = nil, gender: String? = nil, weight: Double? = nil,
         imageData: Data? = nil, notes: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.breed = breed
        self.birthday = birthday
        self.gender = gender
        self.weight = weight
        self.imageData = imageData
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // ペットの年齢を計算
    var age: String {
        guard let birthday = birthday else {
            return "不明"
        }
        return DateUtils.calculateAge(birthdate: birthday)
    }
    
    // ペットのタイプに基づく表示アイコン名を返す
    var iconName: String {
        switch type.lowercased() {
        case "dog":
            return "pawprint.fill"
        case "cat":
            return "cat.fill"
        case "bird":
            return "bird.fill"
        case "fish":
            return "water.waves"
        default:
            return "pawprint"
        }
    }
    
    // ペットのタイプに基づく色を返す
    var typeColor: Color {
        switch type.lowercased() {
        case "dog":
            return .dogColor
        case "cat":
            return .catColor
        case "bird":
            return .birdColor
        case "fish":
            return .fishColor
        default:
            return .otherPetColor
        }
    }
    
    // ペットの性別に基づくテキストを返す
    var genderText: String {
        guard let gender = gender else {
            return "不明"
        }
        
        switch gender.lowercased() {
        case "male":
            return "オス"
        case "female":
            return "メス"
        default:
            return gender
        }
    }
    
    // ペットの種類の日本語表記を返す
    var typeText: String {
        switch type.lowercased() {
        case "dog":
            return "犬"
        case "cat":
            return "猫"
        case "bird":
            return "鳥"
        case "fish":
            return "魚"
        default:
            return type
        }
    }
    
    // フォーマットされた体重の文字列を返す
    var weightText: String {
        guard let weight = weight else {
            return "未測定"
        }
        return String(format: "%.1f kg", weight)
    }
    
    // UIImage オブジェクトを返す
    var image: UIImage? {
        guard let imageData = imageData else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

// MARK: - サンプルデータ
extension PetModel {
    static var sampleData: [PetModel] {
        [
            PetModel(
                name: "モカ",
                type: "dog",
                breed: "柴犬",
                birthday: Calendar.current.date(byAdding: .year, value: -3, to: Date()),
                gender: "female",
                weight: 8.5,
                notes: "元気いっぱいの柴犬です。散歩が大好きで、毎日朝夕2回の散歩を欠かしません。"
            ),
            PetModel(
                name: "ミケ",
                type: "cat",
                breed: "三毛猫",
                birthday: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
                gender: "male",
                weight: 4.2,
                notes: "人懐っこい三毛猫です。いつもソファで寝ています。"
            ),
            PetModel(
                name: "ピーちゃん",
                type: "bird",
                breed: "セキセイインコ",
                birthday: Calendar.current.date(byAdding: .month, value: -14, to: Date()),
                gender: "female",
                weight: 0.035,
                notes: "青色のセキセイインコです。歌うのが得意です。"
            )
        ]
    }
}
