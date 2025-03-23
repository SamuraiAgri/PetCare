// PetCare/Common/CommonComponents.swift

import SwiftUI

// MARK: - カード表示用コンポーネント
struct CardView<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    var backgroundColor: Color = .secondaryBackgroundColor
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 4
    
    init(
        padding: CGFloat = 16,
        backgroundColor: Color = .secondaryBackgroundColor,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: shadowRadius, x: 0, y: 2)
    }
}

// MARK: - ペットアイコン表示用コンポーネント
struct PetAvatarView: View {
    var imageData: Data?
    var name: String
    var size: CGFloat
    var petType: String
    
    var body: some View {
        ZStack {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(petTypeColor(type: petType))
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func petTypeColor(type: String) -> Color {
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
}

// MARK: - ヘッダーコンポーネント
struct HeaderView: View {
    var title: String
    var subtitle: String? = nil
    var showBackButton: Bool = false
    var onBackTapped: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            if showBackButton {
                Button(action: {
                    onBackTapped?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primaryColor)
                }
                .padding(.trailing, 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.primaryTextColor)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondaryTextColor)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.backgroundColor)
    }
}

// MARK: - プライマリボタン
struct PrimaryButton: View {
    var title: String
    var icon: String? = nil
    var isFullWidth: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.bodyMedium)
                }
                
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

// MARK: - セカンダリボタン
struct SecondaryButton: View {
    var title: String
    var icon: String? = nil
    var isFullWidth: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.bodyMedium)
                }
                
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color.white)
            .foregroundColor(.primaryColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryColor, lineWidth: 1)
            )
        }
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    var title: String
    var message: String
    var iconName: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 70))
                .foregroundColor(.tertiaryTextColor)
                .padding(.bottom, 10)
            
            Text(title)
                .font(.title3)
                .foregroundColor(.primaryTextColor)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.bodyMedium)
                .foregroundColor(.secondaryTextColor)
                .multilineTextAlignment(.center)
            
            if let buttonTitle = buttonTitle, let action = action {
                PrimaryButton(title: buttonTitle, action: action)
                    .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - カスタムDivider
struct CustomDivider: View {
    var color: Color = .tertiaryTextColor.opacity(0.3)
    var height: CGFloat = 1
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
    }
}

// MARK: - タグ表示用コンポーネント
struct TagView: View {
    var text: String
    var color: Color
    var fontSize: CGFloat = 12
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

// MARK: - ステータスインジケーター
struct StatusIndicator: View {
    enum Status {
        case success
        case warning
        case error
        case info
        
        var color: Color {
            switch self {
            case .success:
                return .successColor
            case .warning:
                return .warningColor
            case .error:
                return .errorColor
            case .info:
                return .infoColor
            }
        }
        
        var iconName: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .warning:
                return "exclamationmark.triangle.fill"
            case .error:
                return "xmark.circle.fill"
            case .info:
                return "info.circle.fill"
            }
        }
    }
    
    var status: Status
    var text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .foregroundColor(status.color)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondaryTextColor)
        }
    }
}
