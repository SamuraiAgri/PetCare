// PetCare/Common/Font+Extension.swift

import SwiftUI

extension Font {
    // タイトル用フォント
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // 本文用フォント
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .rounded)
    
    // 見出し用フォント
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)
    
    // キャプション用フォント
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
}

struct FontModifier: ViewModifier {
    let font: Font
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

extension View {
    // タイトル用スタイル
    func largeTitleStyle() -> some View {
        self.modifier(FontModifier(font: .largeTitle, color: .primaryTextColor))
    }
    
    func titleStyle() -> some View {
        self.modifier(FontModifier(font: .title, color: .primaryTextColor))
    }
    
    func title2Style() -> some View {
        self.modifier(FontModifier(font: .title2, color: .primaryTextColor))
    }
    
    func title3Style() -> some View {
        self.modifier(FontModifier(font: .title3, color: .primaryTextColor))
    }
    
    // 本文用スタイル
    func bodyLargeStyle() -> some View {
        self.modifier(FontModifier(font: .bodyLarge, color: .primaryTextColor))
    }
    
    func bodyMediumStyle() -> some View {
        self.modifier(FontModifier(font: .bodyMedium, color: .primaryTextColor))
    }
    
    func bodySmallStyle() -> some View {
        self.modifier(FontModifier(font: .bodySmall, color: .secondaryTextColor))
    }
    
    // 見出し用スタイル
    func headlineStyle() -> some View {
        self.modifier(FontModifier(font: .headline, color: .primaryTextColor))
    }
    
    func subheadlineStyle() -> some View {
        self.modifier(FontModifier(font: .subheadline, color: .secondaryTextColor))
    }
    
    // キャプション用スタイル
    func captionStyle() -> some View {
        self.modifier(FontModifier(font: .caption, color: .tertiaryTextColor))
    }
    
    func caption2Style() -> some View {
        self.modifier(FontModifier(font: .caption2, color: .tertiaryTextColor))
    }
}
