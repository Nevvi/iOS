//
//  ConnectionDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import MessageUI
import MapKit


struct ConnectionDetail: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @EnvironmentObject var messagingStore: MessagingStore
    
    @State var showEditSheet = false
    @State var tabSelectedValue = 0
    
    @State private var showDeleteAlert: Bool = false
    
    private var canText: Bool {
        return self.messagingStore.canSendText() && !self.connectionStore.phoneNumber.isEmpty
    }
    
    private var canCall: Bool {
        return !self.connectionStore.phoneNumber.isEmpty &&
            UIApplication.shared.canOpenURL(URL(string: "tel://\(self.connectionStore.phoneNumber)")!)
    }
    
    private var canMail: Bool {
        return self.messagingStore.canSendMail() && !self.connectionStore.email.isEmpty &&
            !self.accountStore.email.isEmpty
    }
    
    var body: some View {
        if self.connectionStore.loading == false && !self.connectionStore.id.isEmpty {
            ScrollView {
                VStack(spacing: 12) {
                    HStack(alignment: .center) {
                        Spacer()
                        VStack(alignment: .center, spacing: 4) {
                            ProfileImage(imageUrl: self.connectionStore.profileImage, height: 108, width: 108)
                            
                            Text("\(self.connectionStore.firstName) \(self.connectionStore.lastName)")
                                .defaultStyle(size: 22, opacity: 1.0)
                            
                            Text(self.connectionStore.bio)
                                .defaultStyle(size: 16, opacity: 0.6)
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        contactAction(
                            image: "message",
                            text: "Message",
                            enabled: self.canText
                        ).onTapGesture {
                            if self.canText {
                                self.messagingStore.loadSms(recipient: self.connectionStore.phoneNumber)
                                let vc = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
                                
                                vc?.present(self.messagingStore.textComposeVC, animated: true)
                            }
                        }
                        
                        Link(destination: URL(string: "tel:\(self.connectionStore.phoneNumber)")!) {
                            contactAction(
                                image: "phone",
                                text: "Call",
                                enabled: self.canCall
                            )
                        }
                        
                        Link(destination: URL(string: "mailto:\(self.connectionStore.email)")!) {
                            contactAction(
                                image: "envelope",
                                text: "Mail",
                                enabled: self.canMail
                            )
                        }
                    }
                    .padding([.bottom], 16)
                    
                    if !self.connectionStore.phoneNumber.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Phone Number").personalInfoLabel()
                            
                            HStack(alignment: .center, spacing: 8) {
                                Text(self.connectionStore.phoneNumber)
                                    .defaultStyle(size: 16, opacity: 1.0)
                                
                                Spacer()
                                
                                Text("Home").asDefaultBadge()
                            }
                            .padding(.horizontal, 0)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .informationSection(data: self.connectionStore.phoneNumber)
                    }
                    
                    if !self.connectionStore.email.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email").personalInfoLabel()
                            
                            HStack(alignment: .center, spacing: 8) {
                                Text(self.connectionStore.email)
                                    .defaultStyle(size: 16, opacity: 1.0)
                                
                                Spacer()
                                
                                Text("Personal").asDefaultBadge()
                            }
                            .padding(.horizontal, 0)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .informationSection(data: self.connectionStore.email)
                    }
                    
                    if !self.connectionStore.address.isEmpty {
                        HStack(alignment: .center, spacing: 2) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Address").personalInfoLabel()
                                
                                Text(self.connectionStore.address.toString())
                                    .defaultStyle(size: 16, opacity: 1.0)
                                    .padding([.vertical], 8)
                            }
                            
                            Spacer()
                            
                            if self.connectionStore.hasCoordinates  {
                                Map(coordinateRegion: self.$connectionStore.coordinates.coordinates,
                                    interactionModes: [.zoom], annotationItems: [self.connectionStore.coordinates],
                                    annotationContent: { location in
                                    MapPin(coordinate: CLLocationCoordinate2D(latitude: location.coordinates.center.latitude, longitude: location.coordinates.center.longitude), tint: .red)
                                    })
                                    .frame(width: 70, height: 70)
                            }
                        }
                        .informationSection(data: self.connectionStore.address.toString())
                        .onTapGesture {
                            if self.connectionStore.hasCoordinates {
                                let latitude = self.connectionStore.coordinates.coordinates.center.latitude
                                let longitude = self.connectionStore.coordinates.coordinates.center.longitude
                                let url = URL(string: "maps://?address=\(latitude),\(longitude)")
                                if UIApplication.shared.canOpenURL(url!) {
                                      UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                                }
                            }
                        }
                    }
                    
                    if self.connectionStore.birthday.toString() != Date().toString() {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Birthday").personalInfoLabel()
                            
                            Text(self.connectionStore.birthday.toString())
                                .defaultStyle(size: 16, opacity: 1.0)
                                .padding([.vertical], 8)
                        }
                        .informationSection(data: self.connectionStore.birthday.toString())
                    }
                    
                    Spacer()
                    Spacer()
 
                    Text("Delete".uppercased())
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(.red)
                        )
                        .onTapGesture {
                            self.showDeleteAlert = true
                        }
                }
                .padding()
            }
            .background(ColorConstants.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Image(systemName: "square.and.arrow.up")
//                        .toolbarButtonStyle()
//                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "square.and.pencil")
                        .toolbarButtonStyle()
                        .onTapGesture {
                            self.showEditSheet = true
                        }
                }
            })
            .alert(isPresented: self.$showDeleteAlert) {
                deleteAlert
            }
            .sheet(isPresented: self.$showEditSheet) {
                editSheet
            }
        } else  {
            VStack {
                Spacer()
                LoadingView(loadingText: "Fetching connection details...")
                Spacer()
            }
        }
    }
    
    var editSheet: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("", selection: self.$tabSelectedValue) {
                Text("Permission Group".uppercased()).tag(0)
                Text("Connection Groups".uppercased()).tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 24)

            TabView(selection: $tabSelectedValue) {
                editPermissionGroup.tag(0)

                editConnectionGroups.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeIn, value: tabSelectedValue)
            
            Text("Close")
                .asDefaultButton()
                .padding(.horizontal)
                .onTapGesture {
                    self.showEditSheet = false
                }
        }
    }
    
    var editPermissionGroup: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Change Permission Group")
                      .font(Font.custom("SF Pro", size: 20).weight(.medium))
                      .foregroundColor(Color(red: 0.12, green: 0.19, blue: 0.29))
                      .padding([.leading, .bottom], 16)
                    
                    ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                        ZStack(alignment: .top) {
                            PermissionGroupRow(group: group)
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                if self.connectionStore.permissionGroup == group.name {
                                    Image(systemName: "checkmark")
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .background(ColorConstants.primary)
                                        .opacity(self.connectionStore.saving ? 0.5 : 1.0)
                                        .cornerRadius(8)
                                        .fontWeight(.light)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8).stroke(ColorConstants.primary, lineWidth: 1)
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(ColorConstants.badgeText)
                                        .background(.white)
                                        .onTapGesture {
                                            if !self.connectionStore.saving {
                                                self.connectionStore.permissionGroup = group.name
                                                self.connectionStore.update { (result: Result<Connection, Error>) in
                                                    switch result {
                                                    case .success(let connection):
                                                        self.connectionsStore.load()
                                                    case .failure(let error):
                                                        print("Something bad happened", error)
                                                    }
                                                }
                                            }
                                        }
                                }
                            }.padding()
                        }.padding([.horizontal])
                    }
                    .redacted(when: self.accountStore.loading, redactionType: .customPlaceholder)
                }
            }
        }
        .padding([.top], 40)
    }
    
    var editConnectionGroups: some View {
        VStack(spacing: 0) {
            if self.connectionGroupsStore.groups.isEmpty {
                HStack(alignment: .center) {
                    if self.connectionGroupsStore.loading {
                        ProgressView()
                    } else {
                        VStack(alignment: .center, spacing: 24) {
                            Image("UpdateProfile")
                            
                            Text("No connection groups.\nCreate connection groups in your settings.")
                                .defaultStyle(size: 24, opacity: 1.0)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Connection Group(s)")
                            .font(Font.custom("SF Pro", size: 20).weight(.medium))
                            .foregroundColor(Color(red: 0.12, green: 0.19, blue: 0.29))
                            .padding([.leading, .bottom], 16)
                        
                        ForEach(self.connectionGroupsStore.groups, id: \.name) { group in
                            ZStack(alignment: .trailing) {
                                ConnectionGroupRow(connectionGroup: group)
                                
                                Spacer()
                                
                                if group.connections.contains(self.connectionStore.id) {
                                    Image(systemName: "checkmark")
                                        .toolbarButtonStyle(bgColor: ColorConstants.primary)
                                        .foregroundColor(.white)
                                        .opacity(self.connectionGroupsStore.loading ? 0.5 : 1.0)
                                        .opacity(self.connectionGroupsStore.loading ? 0.5 : 1.0)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            self.connectionGroupsStore.removeFromGroup(groupId: group.id, userId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                                                switch result {
                                                case .success(_):
                                                    self.connectionGroupsStore.load()
                                                case .failure(let error):
                                                    print("Failed to remove from group", error)
                                                }
                                            }
                                        }
                                } else {
                                    Image(systemName: "plus")
                                        .toolbarButtonStyle()
                                        .opacity(self.connectionGroupsStore.loading ? 0.5 : 1.0)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            self.connectionGroupsStore.addToGroup(groupId: group.id, userId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                                                switch result {
                                                case .success(_):
                                                    self.connectionGroupsStore.load()
                                                case .failure(let error):
                                                    print("Failed to add to group", error)
                                                }
                                            }
                                        }
                                }
                            }.padding(.horizontal)
                        }
                        .redacted(when: self.accountStore.loading, redactionType: .customPlaceholder)
                    }
                }
            }
        }
        .padding([.top], 40)
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove this connection?"), primaryButton: .destructive(Text("Delete")) {
            self.connectionStore.delete(connectionId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                switch result {
                case.success(_):
                    self.connectionsStore.load()
                    self.connectionsStore.loadOutOfSync(callback: { _ in })
                    self.connectionsStore.loadRejectedUsers()
                    self.presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Something bad happened", error)
                }
            }
            
            self.showDeleteAlert = false
        }, secondaryButton: .cancel() {
            self.showDeleteAlert = false
        })
    }
    
    func contactAction(image: String, text: String, enabled: Bool) -> some View {
        let fgColor = enabled ? ColorConstants.primary : .gray
        
        return VStack(alignment: .center, spacing: 8) {
            Image(systemName: image)
                .frame(width: 24, height: 24)
                .foregroundColor(fgColor)
            
            Text(text)
                .foregroundColor(fgColor)
                .defaultStyle(size: 13, opacity: 0.6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.white)
        .cornerRadius(12)
    }
}

struct ConnectionDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionStore = ConnectionStore(connection: modelData.connection)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)

    static var previews: some View {
        ConnectionDetail()
            .environmentObject(accountStore)
            .environmentObject(connectionGroupsStore)
            .environmentObject(connectionStore)
            .environmentObject(connectionsStore)
            .environmentObject(MessagingStore())
    }
}
