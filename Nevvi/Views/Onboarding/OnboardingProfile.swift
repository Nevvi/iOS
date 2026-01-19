//
//  OnboardingViewOne.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingProfile: View {
    @EnvironmentObject var accountStore: AccountStore
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showBirthdayPicker: Bool = false
    @State private var showAddressSearch: Bool = false
    
    @State var saving: Bool = false
    
    var primaryClick: () -> Void
    
    var isButtonDisabled: Bool {
        return self.accountStore.firstName.isEmpty || self.accountStore.lastName.isEmpty || self.saving
    }
    
    private var isBirthdayEmpty: Bool {
        return self.accountStore.birthday.yyyyMMdd() == Date().yyyyMMdd()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
            }
            
            VStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 12) {
                        Image("AppLogo")
                            .frame(width: 68, height: 68)
                            .padding([.top], geometry.size.height * 0.08)
                            .padding(.bottom)
                        
                        Text("Let's create your profile!")
                            .defaultStyle(size: 30)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("How do you want to appear to others?")
                            .defaultStyle(size: 14)
                            .multilineTextAlignment(.center)
                            .padding([.bottom, .leading, .trailing])
                        
                        HStack(spacing: 16) {
                            Spacer()
                            ProfileImageSelector(height: 73, width: 73)
                            VStack(alignment: .leading) {
                                Text("Upload your profile picture").defaultStyle(size: 16, opacity: 0.7)
                                    .fontWeight(.regular)
                                Text("(Optional)").defaultStyle(size: 16, opacity: 0.7)
                                    .fontWeight(.regular)
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        VStack {
                            HStack {
                                Text("Name").defaultStyle(size: 16, opacity: 0.7)
                                    .fontWeight(.regular)
                                Spacer()
                                Text("Required").defaultStyle(size: 16, opacity: 0.7)
                                    .fontWeight(.light)
                            }
                            
                            HStack {
                                TextField("First", text: self.$accountStore.firstName)
                                    .onboardingStyle()
                                
                                TextField("Last", text: self.$accountStore.lastName)
                                    .onboardingStyle()
                            }
                        }
                        
                        VStack {
                            HStack {
                                Text("Address").defaultStyle(size: 16, opacity: 0.7)
                                    .fontWeight(.regular)
                                Spacer()
                                Text("Optional").defaultStyle(size: 16, opacity: 0.7)
                                    .fontWeight(.light)
                            }
                            
                            Text(self.accountStore.address.isEmpty ? "Enter your address" : self.accountStore.address.toString())
                                .font(.system(size: 16, weight: self.accountStore.address.isEmpty ? .ultraLight : .regular))
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .onTapGesture {
                                    self.showAddressSearch = true
                                }
                        }
                        
                        VStack {
                            HStack {
                                Text("Birthday").defaultStyle(size: 16, opacity: 0.7)
                                    .fontWeight(.regular)
                                Spacer()
                                Text("Optional").defaultStyle(size: 16, opacity: 0.7)
                                    .fontWeight(.light)
                            }
                            
                            ZStack {
                                Text(self.isBirthdayEmpty ? "MM / DD / YYYY" : self.accountStore.birthday.toString())
                                    .font(.system(size: 16, weight: self.isBirthdayEmpty ? .ultraLight : .regular))
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    .onTapGesture {
                                        self.showBirthdayPicker = true
                                    }
                                
                                HStack {
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color.gray.opacity(0.7))
                                        .padding(.trailing, 16)
                                }
                            }.padding(.top, 1)
                        }
                    }
                    .padding([.leading, .trailing])
                }
             
                Spacer()
                
                OnboardingButton(text: "Continue", loading: self.accountStore.saving, action: self.primaryAction)
                    .disabled(self.isButtonDisabled)
                    .opacity(self.isButtonDisabled ? 0.5 : 1.0)
            }
        }
        .sheet(isPresented: self.$showBirthdayPicker) {
            datePickerSheet
        }
        .sheet(isPresented: self.$showAddressSearch) {
            AddressSearch(address: self.accountStore.address, callback: { address in
                self.accountStore.address = address
                self.showAddressSearch = false
            }).presentationDetents([.large])
        }
        .edgesIgnoringSafeArea([.top])
    }
    
    var datePickerSheet: some View {
        DynamicSheet(
            VStack(spacing: 8) {
                DatePicker("", selection: self.$accountStore.birthday, displayedComponents: [.date])
                    .datePickerStyle(.wheel)
                    .padding(.trailing)
                
                Text("Confirm")
                    .asPrimaryButton()
                    .onTapGesture {
                        self.showBirthdayPicker = false
                    }
            }.padding(.horizontal)
        )
    }
    
    func primaryAction() {
        self.saving = true
        self.accountStore.save { res in
            switch(res) {
            case .success(_):
                self.saving = false
                self.primaryClick()
            case .failure(let err):
                print("Failed to save profile", err)
                self.saving = false
            }
        }
    }
}

struct OnboardingProfile_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingProfile(primaryClick: {})
        .environmentObject(accountStore)
    }
}
