//
//  ActionableConnectionRequestRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ActionableConnectionRequestRow: View {
    var myUser: User
    var approvalCallback: (String, String) -> Void
    
    @State var request: ConnectionRequest
    @State var showSheet: Bool = false
    @State var selectedPermissionGroup: String = "ALL"
    
    var body: some View {
        HStack {
            ZStack {
                AsyncImage(url: URL(string: self.request.requesterImage), content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }, placeholder: {
                    ProgressView()
                        .padding(15)
                }).padding([.trailing], 10)
            }
            
            Text(self.request.requestText)
            
            Spacer()
            
            Button { self.showSheet = true } label: {
                Text("Approve")
            }
        }
        .padding(5)
        .sheet(isPresented: self.$showSheet) {
            ZStack {
                VStack {
                    Text("Which permission group should this new connection belong to?")
                        .font(.title2)
                        .padding([.top, .leading, .trailing])
                                        
                    CheckboxGroup(items: self.myUser.permissionGroups.map({ (group: PermissionGroup) in
                        return CheckboxItem(name: group.name, value: group.name)
                    }), selectedItem: self.$selectedPermissionGroup)
                    .padding([.leading, .trailing])
                    
                    
                    Button(action: {
                        self.approvalCallback(self.request.requestingUserId, self.selectedPermissionGroup)
                        self.showSheet = false
                    }, label: {
                        Text("Confirm")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(Color(UIColor(hexString: "#49C5B6")))
                            )
                    })
                }
            }.presentationDetents([.medium])
        }
    }
}

struct ActionableConnectionRequestRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        ActionableConnectionRequestRow(myUser: modelData.user,
                          approvalCallback: { (id: String, group: String) in
            print(id, group)
        }, request: modelData.requests[0])
            .environmentObject(modelData)
    }
}
