// PetCare/Models/CoreDataEntities.swift

import Foundation
import CoreData
import SwiftUI
import UIKit

// CoreData拡張 - 機能追加のみを行い、クラス定義はXcodeが自動生成したものを使用

// MARK: - Pet拡張
extension Pet {
    // ヘルパーメソッドや計算プロパティを追加
    var formattedBirthday: String? {
        guard let birthday = self.birthday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: birthday)
    }
    
    var age: String {
        guard let birthday = self.birthday else {
            return "不明"
        }
        return DateUtils.calculateAge(birthdate: birthday)
    }
    
    var genderText: String {
        guard let gender = self.gender else {
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
    
    var typeColor: UIColor {
        switch self.type?.lowercased() ?? "" {
        case "dog":
            return UIColor(Color.dogColor)
        case "cat":
            return UIColor(Color.catColor)
        case "bird":
            return UIColor(Color.birdColor)
        case "fish":
            return UIColor(Color.fishColor)
        default:
            return UIColor(Color.otherPetColor)
        }
    }
    
    var typeText: String {
        switch self.type?.lowercased() ?? "" {
        case "dog":
            return "犬"
        case "cat":
            return "猫"
        case "bird":
            return "鳥"
        case "fish":
            return "魚"
        default:
            return self.type ?? "不明"
        }
    }
    
    var image: UIImage? {
        guard let imageData = self.imageData else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

// MARK: - HealthRecord拡張
extension HealthRecord {
    // ヘルパーメソッドや計算プロパティを追加
    var formattedDate: String {
        guard let date = self.date else { return "不明" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    var formattedWeight: String? {
        return self.weight > 0 ? String(format: "%.1f kg", self.weight) : nil
    }
    
    var formattedTemperature: String? {
        return self.temperature > 0 ? String(format: "%.1f °C", self.temperature) : nil
    }
    
    var hasSymptoms: Bool {
        return self.symptoms != nil && !self.symptoms!.isEmpty
    }
    
    var hasMedications: Bool {
        return self.medications != nil && !self.medications!.isEmpty
    }
}

// MARK: - Vaccination拡張
extension Vaccination {
    // ヘルパーメソッドや計算プロパティを追加
    var formattedDate: String {
        guard let date = self.date else { return "不明" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    var formattedExpiryDate: String? {
        guard let expiryDate = self.expiryDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: expiryDate)
    }
    
    var isExpired: Bool {
        guard let expiryDate = self.expiryDate else {
            return false
        }
        return expiryDate < Date()
    }
    
    var daysUntilExpiry: Int? {
        guard let expiryDate = self.expiryDate else {
            return nil
        }
        return DateUtils.daysRemaining(until: expiryDate)
    }
}

// MARK: - MealSchedule拡張
extension MealSchedule {
    // ヘルパーメソッドや計算プロパティを追加
    var formattedTime: String {
        guard let time = self.time else { return "不明" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var formattedAmount: String {
        return String(format: "%.0f g", self.amount)
    }
    
    var weekdaysArray: [Int] {
        guard let daysOfWeek = self.daysOfWeek else {
            return []
        }
        
        return daysOfWeek.split(separator: ",")
            .compactMap { Int($0) }
            .filter { $0 >= 1 && $0 <= 7 }
    }
}

// MARK: - Supply拡張
extension Supply {
    // ヘルパーメソッドや計算プロパティを追加
    var formattedExpiryDate: String? {
        guard let expiryDate = self.expiryDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: expiryDate)
    }
    
    var formattedQuantity: String {
        return String(format: "%.1f %@", self.quantity, self.unit ?? "")
    }
    
    var isLowStock: Bool {
        return self.quantity <= self.alertThreshold
    }
}

// MARK: - Appointment拡張
extension Appointment {
    // ヘルパーメソッドや計算プロパティを追加
    var formattedDate: String {
        guard let date = self.date else { return "不明" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    var formattedTime: String? {
        guard let time = self.time else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var typeColor: UIColor {
        switch self.type?.lowercased() ?? "" {
        case "vet":
            return UIColor(Color.primaryColor)
        case "grooming":
            return UIColor(Color.secondaryColor)
        default:
            return UIColor(Color.accentColor)
        }
    }
    
    var typeText: String {
        switch self.type?.lowercased() ?? "" {
        case "vet":
            return "獣医"
        case "grooming":
            return "トリミング"
        default:
            return "その他"
        }
    }
}
