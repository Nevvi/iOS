//
//  ConnectionRequest.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI
import NukeUI

struct NewConnectionRequestRow: View {
    @EnvironmentObject var usersStore: UsersStore
    
    var requestCallback: () -> Void
        
    @State var user: Connection
    @State var loading: Bool = false
    @State var showSheet: Bool = false
    @State private var animate = false
    @State var selectedPermissionGroup: String = "ALL"
    
    var showConnectButton: Bool {
        if (user.connected != nil && user.connected!) {
            return false
        }
        
        if (user.requested != nil && user.requested!) {
            return false
        }
        
        return true
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            ConnectionRow(connection: self.user)
            
            Spacer()
            
            Image(systemName: "plus")
                .toolbarButtonStyle()
                .onTapGesture {
                    self.showSheet = true
                }
                .padding()
        }
        .sheet(isPresented: self.$showSheet) {
            requestConnectionSheet
        }
    }
    
    var requestConnectionSheet: some View {
        DynamicSheet(
            ZStack {
                VStack(alignment: .leading) {
                    Text("Select permission group")
                        .font(.title)
                        .fontWeight(.light)
                        .padding([.leading, .trailing, .top])
                        .padding([.bottom], 6)
                    
                    PermissionGroupPicker(selectedGroup: $selectedPermissionGroup)
                    
                    Spacer()
                    
                    Button(action: self.requestConnection) {
                        Text("Request Connection")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .foregroundColor(ColorConstants.primary)
                            )
                            .opacity(self.loading ? 0.5 : 1.0)
                    }
                    .disabled(self.loading)
                    .padding()
                    .padding([.top], 12)
                }.padding(4)
            }
        )
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
        }
    }
    
}

struct ConnectionRequest_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        NewConnectionRequestRow(requestCallback: {},user: modelData.connectionResponse.users[0])
            .environmentObject(usersStore)
    }
}
