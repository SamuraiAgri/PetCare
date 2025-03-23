// PetCare/Views/GuideView.swift

import SwiftUI

struct GuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("ペットケアガイド")
                    .font(.largeTitle)
                    .padding(.horizontal)
                
                Text("この機能は準備中です")
                    .foregroundColor(.secondaryTextColor)
                    .padding(.horizontal)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.tertiaryTextColor)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .padding(.vertical)
        }
        .background(Color.backgroundColor)
    }
}

struct GuideView_Previews: PreviewProvider {
    static var previews: some View {
        GuideView()
    }
}
