//
//  ConnectionRequest.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI
import NukeUI

struct ConnectionInviteRow: View {
    @EnvironmentObject var usersStore: UsersStore
    
    var requestCallback: () -> Void
    @Binding var selectedReason: InviteReason
        
    @State var user: ContactStore.ContactInfo!
    @State var loading: Bool = false
    @State var showSheet: Bool = false
    @State private var animate = false
    @State var selectedPermissionGroup: String = "All Info"
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let imageData = self.user.image {
                Image(uiImage: UIImage(data: imageData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 63, height: 63)
                    .cornerRadius(63)
            } else {
                Image(systemName: "person.circle.fill") // Placeholder if no image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 63, height: 63)
                    .cornerRadius(63)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(self.user.firstName) \(self.user.lastName)")
                    .defaultStyle(size: 18, opacity: 1.0)
                
                Text("\(self.user.phoneNumber)")
                    .defaultStyle(size: 14, opacity: 0.7)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 64)
            }
            
            Spacer()
            
            Image(systemName: "plus")
                .toolbarButtonStyle()
                .onTapGesture {
                    self.showSheet = true
                }
                .padding()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.04), lineWidth: 1)
        )
        .sheet(isPresented: self.$showSheet) {
            inviteUserSheet
        }
    }
    
    var inviteUserSheet: some View {
        DynamicSheet(
            ZStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Select permission group")
                        .font(.title2)
                        .fontWeight(.light)
                        .padding([.leading, .trailing, .top])
                    
                    PermissionGroupPicker(selectedGroup: $selectedPermissionGroup)
                    
                    Text("Invite reason")
                        .font(.title2)
                        .fontWeight(.light)
                        .padding([.leading, .trailing])
                    
                    Picker("Invite Reason", selection: $selectedReason) {
                        ForEach(InviteReason.allCases, id: \.self) { reason in
                            Text(reason.displayName).tag(reason)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding([.leading, .trailing])
                    .onAppear {
                        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(ColorConstants.primary)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                    }
                    
                    Spacer()
                    
                    Button(action: self.inviteUser) {
                        Text("Invite User")
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
    
    func inviteUser() {
        self.loading = true
        self.usersStore.inviteConnection(phoneNumber: self.user.phoneNumber, groupName: self.selectedPermissionGroup, reason: self.selectedReason.rawValue) { (result: Result<Bool, Error>) in
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

struct ConnectionInviteRow_Preview: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionInviteRow(
            requestCallback: {}, 
            selectedReason: .constant(.other),
            user: ContactStore.ContactInfo(firstName: "John", lastName: "Doe", phoneNumber: "6129631237")
        )
        .environmentObject(usersStore)
    }
}
