//
//  ConnectionRequest.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct NewConnectionRequestRow: View {
    @ObservedObject var accountStore: AccountStore
    var requestCallback: (String, String) -> Void
    
    @State var user: Connection
    
    @State var showSheet: Bool = false
    @State var selectedPermissionGroup: String = "ALL"
    
    var body: some View {
        HStack {
            ZStack {
                AsyncImage(url: URL(string: user.profileImage), content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }, placeholder: {
                    ProgressView()
                        .padding(15)
                }).padding([.trailing], 10)
            }
            
            Text("\(user.firstName) \(user.lastName)")
            
            Spacer()
            
            Button { self.showSheet = true } label: {
                Text("Connect")
            }
        }
        .padding([.top, .bottom], 5)
        .padding([.leading, .trailing], 5)
        .sheet(isPresented: self.$showSheet) {
            ZStack {
                VStack {
                    Text("Which permission group should \(self.user.firstName) belong to?")
                        .font(.title2)
                        .padding([.top])
                                        
                    CheckboxGroup(items: self.accountStore.permissionGroups.map({ (group: PermissionGroup) in
                        return CheckboxItem(name: group.name, value: group.name)
                    }), selectedItem: self.$selectedPermissionGroup)
                    .padding([.leading, .trailing])
                    
                    
                    Button(action: {
                        self.requestCallback(self.user.id, self.selectedPermissionGroup)
                        self.showSheet = false
                    }, label: {
                        Text("Request")
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

struct ConnectionRequest_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        NewConnectionRequestRow(accountStore: accountStore,
                          requestCallback: { (id: String, group: String) in
            print(id, group)
        }, user: modelData.connectionResponse.users[0])
            .environmentObject(modelData)
    }
}
