// PetCare/Views/SuppliesView.swift

import SwiftUI
import CoreData

struct SuppliesView: View {
    // 状態変数
    @State private var supplies: [Supply] = []
    @State private var showAddSupplySheet = false
    
    var body: some View {
        VStack {
            Text("用品在庫管理")
                .font(.title)
                .padding()
            
            Text("この機能は準備中です")
                .foregroundColor(.secondaryTextColor)
                .padding()
            
            Image(systemName: "cube.box.fill")
                .font(.system(size: 60))
                .foregroundColor(.tertiaryTextColor)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}

struct SuppliesView_Previews: PreviewProvider {
    static var previews: some View {
        SuppliesView()
    }
}
