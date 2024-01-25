//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionGroupList: View {
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @EnvironmentObject var connectionGroupStore: ConnectionGroupStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    
    @State private var newGroupName: String = ""
    @State private var showGroupForm: Bool = false
    
    @State private var showGroupDetails: Bool = false
        
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack {
                    if self.connectionGroupsStore.groupsCount == 0 {
                        noGroupsView
                    } else {
                        groupsView
                    }
                }.padding([.top])
            }
            
            Spacer()
            
            HStack {
                Button {
                    self.showGroupForm = true
                } label: {
                    Text("New Connection Group".uppercased())
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(ColorConstants.primary)
                        )
                }
            }.padding()
        }
        .refreshable {
            self.connectionGroupsStore.load()
        }
        .sheet(isPresented: self.$showGroupDetails, content: {
            ConnectionGroupDetail()
        })
        .alert("Create Group", isPresented: $showGroupForm, actions: {
            TextField("Group Name", text: self.$newGroupName)
            Button("Cancel", role: .cancel, action: {})
            Button("Create") {
                self.connectionGroupsStore.create(name: self.newGroupName) { (result: Result<ConnectionGroup, Error>) in
                    switch result {
                    case .success(_):
                        self.showGroupForm = false
                        self.connectionGroupsStore.load()
                    case .failure(let error):
                        print("Something bad happened", error)
                    }
                    self.newGroupName = ""
                }
            }
        })
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
    }
    
    var noGroupsView: some View {
        HStack {
            Spacer()
            if self.connectionGroupsStore.loading {
                ProgressView()
            } else {
                NoDataFound(imageName: "person.2.slash", height: 100, width: 120)
            }
            Spacer()
        }
        .padding([.top], 100)
    }
    
    var groupsView: some View {
        ForEach(self.connectionGroupsStore.groups, id: \.id) { group in
            ConnectionGroupRow(connectionGroup: group, actionable: true)
            .padding([.leading, .trailing, .bottom])
            .onTapGesture {
                self.connectionGroupStore.load(group: group)
                self.showGroupDetails = true
            }
        }
        .redacted(when: self.connectionGroupsStore.loading, redactionType: .customPlaceholder)
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete group?"), message: Text("Are you sure you want to delete this group?"), primaryButton: .destructive(Text("Delete")) {
                for index in self.toBeDeleted! {
                    let groupId = self.connectionGroupsStore.groups[index].id
                    self.connectionGroupsStore.delete(groupId: groupId) { (result: Result<Bool, Error>) in
                        switch result {
                        case.success(_):
                            self.connectionGroupsStore.load()
                        case .failure(let error):
                            print("Something bad happened", error)
                        }
                    }
                }
                
                self.toBeDeleted = nil
                self.showDeleteAlert = false
            }, secondaryButton: .cancel() {
                self.toBeDeleted = nil
                self.showDeleteAlert = false
            }
        )
    }
    
    func delete(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showDeleteAlert = true
        print(offsets)
    }
}

struct ConnectionGroupList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionGroupList()
            .environmentObject(connectionGroupsStore)
            .environmentObject(connectionGroupStore)
            .environmentObject(accountStore)
    }
}
