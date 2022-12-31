//
//  CheckboxGroup.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct CheckboxGroup: View {
    @State var items: [CheckboxItem]
    @Binding var selectedItem: String
    
    var body: some View {
        List {
            ForEach(items, id: \.name) { item in
                HStack {
                    if self.selectedItem == item.value {
                        Rectangle()
                            .frame(width: 30, height: 30)
                            .border(Color(UIColor(hexString: "#33897F")))
                            .foregroundColor(Color(UIColor(hexString: "#33897F")))
                    } else {
                        Rectangle()
                            .frame(width: 30, height: 30)
                            .border(Color(UIColor(hexString: "#33897F")))
                            .foregroundColor(.white)
                    }
                    
                    Text(item.name)
                        .padding(10)
                }.onTapGesture {
                    self.selectedItem = item.value
                }.listRowSeparator(.hidden)
            }
        }.scrollContentBackground(.hidden)
    }
}

struct CheckboxItem {
    var name: String
    var value: String
}

struct CheckboxGroup_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxGroup(items: [
            CheckboxItem(name: "name1", value: "value1"),
            CheckboxItem(name: "name2", value: "value2"),
            CheckboxItem(name: "name3", value: "value3"),
            CheckboxItem(name: "name4", value: "value4"),
        ], selectedItem: Binding(
            get: { "value2" },
            set: { print($0) }
        ))
    }
}
