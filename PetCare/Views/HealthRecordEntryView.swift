// PetCare/Views/HealthRecordEntryView.swift

import SwiftUI

struct HealthRecordEntryView: View {
    // ペットデータ
    private let pet: PetModel?
    
    // 初期化
    init(pet: PetModel?) {
        self.pet = pet
    }
    
    var body: some View {
        if let pet = pet {
            HealthRecordListView(pet: pet)
        } else {
            Text("ペットが選択されていません")
                .foregroundColor(.secondaryTextColor)
                .padding()
        }
    }
}

struct HealthRecordEntryView_Previews: PreviewProvider {
    static var previews: some View {
        HealthRecordEntryView(pet: PetModel.sampleData[0])
    }
}
