//
//  ConnectionSuggestionRow.swift
//  Nevvi
//
//  Created by Tyler Standal on 6/8/24.
//

import SwiftUI

struct ConnectionSuggestionRow: View {
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var suggestionsStore: ConnectionSuggestionStore
    
    var requestCallback: () -> Void
        
    @State var user: Connection
    @State var loading: Bool = false
    @State var showAlert: Bool = false
    @State var showSheet: Bool = false
    @State private var animate = false
    @State var selectedPermissionGroup: String = "All Info"
    
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
            
            if showConnectButton {
                Menu {
                    Button {
                        self.showAlert = true
                    } label: {
                        Label("Ignore", systemImage: "trash")
                    }
                    
                    Button {
                        self.showSheet = true
                    } label: {
                        Label("Request", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(.gray)
                }
                .padding([.trailing], 24)
//                HStack {
//                    Image(systemName: "trash")
//                        .toolbarButtonStyle()
//                        .onTapGesture {
//                            self.showAlert = true
//                        }
//
//                    Image(systemName: "plus")
//                        .toolbarButtonStyle()
//                        .onTapGesture {
//                            self.showSheet = true
//                        }
//                }
//                .padding()
            }
        }
        .sheet(isPresented: self.$showSheet) {
            requestConnectionSheet
        }
        .alert(isPresented: self.$showAlert) {
            ignoreSuggestionAlert
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
    
    var ignoreSuggestionAlert: Alert {
        Alert(title: Text("Confirmation"), message: Text("Are you sure you want to ignore this suggestion?"), primaryButton: .destructive(Text("Ignore")) {
            self.ignoreSuggestion()
            
            self.showAlert = false
        }, secondaryButton: .cancel() {
            self.showAlert = false
        })
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
    
    func ignoreSuggestion() {
        self.loading = true
        self.suggestionsStore.ignoreSuggestion(suggestionId: self.user.id) { (result: Result<Bool, Error>) in
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

struct ConnectionSuggestionRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let suggestionsStore = ConnectionSuggestionStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionSuggestionRow(requestCallback: {},user: modelData.connectionResponse.users[0])
            .environmentObject(usersStore)
    }
}
