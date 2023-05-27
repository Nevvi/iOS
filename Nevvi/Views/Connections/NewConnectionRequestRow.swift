//
//  ConnectionRequest.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct NewConnectionRequestRow: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var usersStore: UsersStore
    
    var requestCallback: () -> Void
        
    @State var user: Connection
    @State var loading: Bool = false
    @State var showSheet: Bool = false
    @State private var animate = false
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
        .opacity(animate ? 0.0 : 1.0)
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
                    .foregroundColor(.black)
                
                Picker("Which permission group should \(self.user.firstName) belong to?", selection: self.$selectedPermissionGroup) {
                    ForEach(self.accountStore.permissionGroups, id: \.name) {
                        Text($0.name.uppercased())
                    }
                }
                .pickerStyle(.wheel)
                .padding([.top], -30)
                .padding([.bottom], 10)
                .foregroundColor(.black)
                
                Button(action: self.requestConnection, label: {
                    Text("Request")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(ColorConstants.secondary)
                        )
                        .opacity(self.loading ? 0.5 : 1.0)
                })
                .disabled(self.loading)
                .padding([.bottom])
            }
        }.presentationDetents([.height(400)])
    }
    
    func requestConnection() {
        self.loading = true
        self.usersStore.requestConnection(userId: self.user.id, groupName: self.selectedPermissionGroup) { (result: Result<Bool, Error>) in
            switch result {
            case .success(_):
                withAnimation(Animation.spring().speed(0.75)) {
                    animate = true
                    self.requestCallback()
                }
            case .failure(let error):
                print("Something bad happened", error)
            }
            self.loading = false
            self.showSheet = false
            withAnimation(Animation.spring().speed(0.75)) {
                animate = true
                self.requestCallback()
            }
        }
    }
}

struct ConnectionRequest_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        NewConnectionRequestRow(requestCallback: {},user: modelData.connectionResponse.users[0])
            .environmentObject(accountStore)
            .environmentObject(usersStore)
    }
}
