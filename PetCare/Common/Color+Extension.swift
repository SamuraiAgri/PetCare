// PetCare/Common/Color+Extension.swift

import SwiftUI

extension Color {
    // Main theme colors
    static let primaryColor = Color(red: 0.29, green: 0.50, blue: 0.94) // #4A80F0 青みがかった色
    static let secondaryColor = Color(red: 1.0, green: 0.54, blue: 0.40) // #FF8A65 暖かみのあるオレンジ
    static let accentColor = Color(red: 0.49, green: 0.85, blue: 0.34) // #7ED957 明るい緑
    
    // Background colors
    static let backgroundColor = Color(red: 0.97, green: 0.98, blue: 0.98) // #F8F9FA 薄いグレー
    static let secondaryBackgroundColor = Color.white // #FFFFFF 白
    
    // Text colors
    static let primaryTextColor = Color(red: 0.13, green: 0.15, blue: 0.16) // #212529 濃いグレー
    static let secondaryTextColor = Color(red: 0.42, green: 0.46, blue: 0.49) // #6C757D 中間グレー
    static let tertiaryTextColor = Color(red: 0.68, green: 0.71, blue: 0.74) // #ADB5BD 薄いグレー
    
    // Status colors
    static let successColor = Color(red: 0.16, green: 0.65, blue: 0.27) // #28A745 緑
    static let warningColor = Color(red: 1.0, green: 0.76, blue: 0.03) // #FFC107 黄色
    static let errorColor = Color(red: 0.86, green: 0.21, blue: 0.27) // #DC3545 赤
    static let infoColor = Color(red: 0.09, green: 0.64, blue: 0.72) // #17A2B8 水色
    
    // Specialized colors for pet categories
    static let dogColor = Color(red: 0.55, green: 0.36, blue: 0.96) // #8B5CF6 紫
    static let catColor = Color(red: 0.96, green: 0.62, blue: 0.04) // #F59E0B オレンジ
    static let birdColor = Color(red: 0.23, green: 0.51, blue: 0.96) // #3B82F6 青
    static let fishColor = Color(red: 0.02, green: 0.71, blue: 0.83) // #06B6D4 シアン
    static let otherPetColor = Color(red: 0.06, green: 0.73, blue: 0.51) // #10B981 緑
}

// Asset カラーセットの値（開発参考用）
/*
 PrimaryColor: #4A80F0
 SecondaryColor: #FF8A65
 AccentColor: #7ED957
 BackgroundColor: #F8F9FA
 SecondaryBackgroundColor: #FFFFFF
 PrimaryTextColor: #212529
 SecondaryTextColor: #6C757D
 TertiaryTextColor: #ADB5BD
 SuccessColor: #28A745
 WarningColor: #FFC107
 ErrorColor: #DC3545
 InfoColor: #17A2B8
 DogColor: #8B5CF6
 CatColor: #F59E0B
 BirdColor: #3B82F6
 FishColor: #06B6D4
 OtherPetColor: #10B981
 */
