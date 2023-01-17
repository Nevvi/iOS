//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionGroupList: View {
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @ObservedObject var connectionGroupStore: ConnectionGroupStore
    var connectionStore: ConnectionStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    
    @State private var newGroupName: String = ""
    @State private var showGroupForm: Bool = false
        
    var body: some View {
        NavigationView {
            List {
                if self.connectionGroupsStore.groupsCount == 0 {
                    noGroupsView
                } else {
                    groupsView
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                Image(systemName: "plus")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        self.showGroupForm = true
                    }
            })
        }
        
        .sheet(isPresented: self.$showGroupForm, content: {
            createGroupSheet
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
            NavigationLink {
                NavigationLazyView(
                    ConnectionGroupDetail(connectionGroupStore: connectionGroupStore, connectionStore: self.connectionStore)
                        .onAppear {
                            self.connectionGroupStore.load(group: group)
                        }
                )
            } label: {
                ConnectionGroupRow(connectionGroup: group)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .background(BackgroundGradient())
        }
        .onDelete(perform: self.delete)
        .redacted(when: self.connectionGroupsStore.loading, redactionType: .customPlaceholder)
        .listRowSeparator(.hidden)
    }
    
    var createGroupSheet: some View {
        VStack {
            Text("Create Group")
                .font(.title3)
                .padding([.top])
            
            Spacer()
            
            TextField("New Group Name", text: self.$newGroupName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
            
            Spacer()
            
            Button {
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
            } label: {
                Text("Create")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(self.newGroupName.isEmpty ? .gray : Color(UIColor(hexString: "#49C5B6")))
                    )
            }
            .disabled(self.newGroupName.isEmpty)

        }
        .padding()
        .presentationDetents([.height(300)])
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
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    
    static var previews: some View {
        ConnectionGroupList(connectionGroupStore: connectionGroupStore, connectionStore: connectionStore)
            .environmentObject(connectionGroupsStore)
    }
}
