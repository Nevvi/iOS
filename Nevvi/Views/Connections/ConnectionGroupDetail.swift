//
//  ConnectionGroupDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/9/23.
//

import SwiftUI

struct ConnectionGroupDetail: View {
    @ObservedObject var connectionGroupStore: ConnectionGroupStore
    @ObservedObject var connectionStore: ConnectionStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    @StateObject var nameFilter = DebouncedText()
    @State var showExportOptions: Bool = false
    
    var body: some View {
        VStack {
            TextField("Name search", text: self.$nameFilter.debouncedText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                .disableAutocorrection(true)
                .onChange(of: self.nameFilter.debouncedText) { text in
                    self.connectionGroupStore.loadConnections(groupId: self.connectionGroupStore.id, name: text)
                }
                .padding([.leading, .trailing], 30)
                .padding([.top], 15)
            
            List {
                if self.connectionGroupStore.loading || self.connectionGroupStore.connectionCount == 0 {
                    noConnectionsView
                } else {
                    connectionsView
                }
            }
            .padding([.top], -20)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(self.connectionGroupStore.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            Text("Export")
                .padding([.trailing])
                .onTapGesture {
                    self.showExportOptions.toggle()
                }
        })
        .sheet(isPresented: self.$showExportOptions) {
            exportSheet
        }
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
    }
    
    var noConnectionsView: some View {
        HStack {
            Spacer()
            if self.connectionGroupStore.loadingConnections {
                ProgressView()
            } else {
                NoDataFound(imageName: "person.2.slash", height: 100, width: 120)
            }
            Spacer()
        }
        .padding([.top], 100)
    }
    
    var connectionsView: some View {
        ForEach(self.connectionGroupStore.connections) { connection in
            NavigationLink {
                NavigationLazyView(
                    ConnectionDetail(connectionStore: self.connectionStore)
                        .onAppear {
                            self.connectionStore.load(connectionId: connection.id) { (result: Result<Connection, Error>) in
                                switch result {
                                case .success(_):
                                    print("Got connection \(connection.id)")
                                case .failure(let error):
                                    print("Something bad happened", error)
                                }
                            }
                        }
                )
            } label: {
                ConnectionRow(connection: connection)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
        .onDelete(perform: self.delete)
        .redacted(when: self.connectionGroupStore.loadingConnections || self.connectionGroupStore.deleting, redactionType: .customPlaceholder)
    }
    
    var exportSheet: some View {
        VStack {
            Text("We will collect all the latest information available to you for the connections in this group and export it to the email we have for you")
                .foregroundColor(.secondary)
                .fontWeight(.regular)
                .font(.system(size: 16))
                .padding()
                .presentationDetents([.fraction(0.33)])
            
            Spacer()
            
            Button {
                self.connectionGroupStore.exportGroupData { (result: Result<Bool, Error>) in
                    self.showExportOptions = false
                    switch result {
                    case .success(_):
                        print("Success")
                    case .failure(let error):
                        print("Failed to export", error)
                    }
                }
            } label: {
                Text("Confirm")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(self.connectionGroupStore.loading ? .gray : Color(UIColor(hexString: "#49C5B6")))
                    )
            }
            .disabled(self.connectionGroupStore.loading)
        }
        .padding()
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove this connection from the group?"), primaryButton: .destructive(Text("Delete")) {
            for index in self.toBeDeleted! {
                let connectionid = self.connectionGroupStore.connections[index].id
                self.connectionGroupStore.removeFromGroup(userId: connectionid) { (result: Result<Bool, Error>) in
                    switch result {
                    case.success(_):
                        self.connectionGroupStore.loadConnections(groupId: self.connectionGroupStore.id, name: self.nameFilter.text)
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
    }
}

struct ConnectionGroupDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    
    static let connectionStore = ConnectionStore(connection: modelData.connection)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionGroupDetail(connectionGroupStore: connectionGroupStore, connectionStore: connectionStore)
    }
}
