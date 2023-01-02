//
//  ConnectionDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionDetail: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var accountStore: AccountStore
    @ObservedObject var connectionStore: ConnectionStore
    
    @State var showSettings = false

    var body: some View {
        if self.connectionStore.loading == false && !self.connectionStore.id.isEmpty {
            ScrollView {
                AsyncImage(url: URL(string: self.connectionStore.profileImage), content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 100, maxHeight: 100)
                        .clipShape(Circle())
                }, placeholder: {
                    ProgressView()
                        .padding(35)
                })
                
                if !self.connectionStore.email.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Email")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        
                        Text(self.connectionStore.email)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
                
                if !self.connectionStore.phoneNumber.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Phone Number")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        Text(self.connectionStore.phoneNumber)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
                
                if !self.connectionStore.address.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Street Address")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        Text(self.connectionStore.address.street)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
                
                if !(self.connectionStore.birthday == Date()) {
                    VStack(alignment: .leading) {
                        Text("Birthday")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        Text(self.connectionStore.birthday.yyyyMMdd())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
            }
            .navigationTitle("\(self.connectionStore.firstName) \(self.connectionStore.lastName)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button {
                    self.showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .renderingMode(.template)
                        .foregroundColor(.black)
                }
            )
            .sheet(isPresented: self.$showSettings) {
                ZStack {
                    VStack {
                        Text("\(self.connectionStore.firstName)'s connection settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding([.top], 50)
                        
                        Spacer()
                        
                        VStack {
                            Text("Permission Group")
                                .font(.system(size: 20))
                                                        
                            Menu {
                                Picker("Which permission group should \(self.connectionStore.firstName) belong to?", selection: self.$connectionStore.permissionGroup) {
                                    ForEach(self.accountStore.permissionGroups, id: \.name) {
                                        Text($0.name)                                    }
                                }
                            } label: {
                                Text(self.connectionStore.permissionGroup)
                                    .font(.system(size: 20))
                                    .foregroundColor(self.connectionStore.saving ? .gray : Color(UIColor(hexString: "#49C5B6")))
                                    .frame(width: 500)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .disabled(self.connectionStore.saving)
                .presentationDetents([.fraction(0.33)])
                .onChange(of: self.connectionStore.permissionGroup) { newValue in
                    self.connectionStore.update()
                }
            }
        } else  {
            ProgressView()
        }
    }
}

struct ConnectionDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionStore = ConnectionStore(connection: modelData.connection)

    static var previews: some View {
        ConnectionDetail(accountStore: accountStore, connectionStore: connectionStore)
            .environmentObject(modelData)
    }
}
