//
//  ConnectionRequest.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct NewConnectionRequestRow: View {
    @EnvironmentObject var accountStore: AccountStore
    
    var requestCallback: (String, String) -> Void
    
    @State var user: Connection
    
    @State var showSheet: Bool = false
    @State var selectedPermissionGroup: String = "ALL"
    
    var body: some View {
        HStack {
            ProfileImage(imageUrl: user.profileImage, height: 50, width: 50)
                .padding([.trailing], 10)
            
            Text("\(user.firstName) \(user.lastName)")
            
            Spacer()
            
            if user.connected == nil || !user.connected! {
                connectButton
            }
        }
        .padding([.top, .bottom], 5)
        .padding([.leading, .trailing], 5)
        .sheet(isPresented: self.$showSheet) {
            requestConnectionSheet
        }
    }
    
    var connectButton: some View {
        Button {
            self.showSheet = true
        } label: {
            Text("Connect")
        }
    }
    
    var requestConnectionSheet: some View {
        ZStack {
            VStack {
                AsyncImage(url: URL(string: user.profileImage), content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                }, placeholder: {
                    ProgressView()
                        .padding(15)
                }).padding([.top], 30)
                
                Text("Which permission group should \(self.user.firstName) belong to if they accept?")
                    .font(.title2)
                    .padding([.top, .leading, .trailing])
                
                Picker("Which permission group should \(self.user.firstName) belong to?", selection: self.$selectedPermissionGroup) {
                    ForEach(self.accountStore.permissionGroups, id: \.name) {
                        Text($0.name.uppercased())
                    }
                }
                .pickerStyle(.wheel)
                .padding([.top], -25)
                
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
                .padding([.bottom])
            }
        }.presentationDetents([.medium])
    }
}

struct ConnectionRequest_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        NewConnectionRequestRow(requestCallback: { (id: String, group: String) in
            print(id, group)
        }, user: modelData.connectionResponse.users[0])
            .environmentObject(accountStore)
    }
}
