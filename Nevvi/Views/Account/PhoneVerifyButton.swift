//
//  PhoneVerifyButton.swift
//  Nevvi
//
//  Created by Tyler Standal on 2/4/24.
//

import SwiftUI

struct PhoneVerifyButton: View {
    @EnvironmentObject var accountStore: AccountStore
    
    @State private var phoneVerificationCode: String = ""
    @State private var showPhoneVerification: Bool = false
    
    var body: some View {
        HStack {
            if !self.accountStore.phoneNumber.isEmpty && !self.accountStore.phoneNumberConfirmed && self.accountStore.phoneNumber == self.accountStore.user?.phoneNumber {
                Button {
                    self.accountStore.verifyPhone { (result: Result<AccountStore.VerifyPhoneResponse, Error>) in
                        switch result {
                        case .success(_):
                            self.showPhoneVerification = true
                        case .failure(let error):
                            print("Something bad happened", error)
                        }
                    }
                } label: {
                    Text("Verify")
                        .foregroundColor(ColorConstants.primary)
                        .defaultStyle(size: 12, opacity: 1.0)
                        .opacity(self.accountStore.saving ? 0.5 : 1.0)
                        .padding(.trailing, 4)
                }
                .disabled(self.accountStore.saving)
                .fontWeight(.bold)
                .font(.system(size: 14))
            }
        }
        .sheet(isPresented: self.$showPhoneVerification) {
            phoneVerificationSheet
        }
    }
    
    var phoneVerificationSheet: some View {
        VStack(alignment: .center, spacing: 28) {
            Text("Please enter the confirmation code we texted to you")
                .defaultStyle(size: 22, opacity: 1.0)
                .multilineTextAlignment(.center)
            
            TextField("Code", text: self.$phoneVerificationCode)
                .frame(maxWidth: .infinity, alignment: .leading)
                .keyboardType(.numberPad)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                                    
            Button {
                self.accountStore.confirmPhone(code: self.phoneVerificationCode) { (result: Result<AccountStore.ConfirmPhoneResponse, Error>) in
                    switch result {
                    case .success(_):
                        self.accountStore.phoneNumberConfirmed = true
                        self.showPhoneVerification = false
                    case .failure(let error):
                        print("Something bad happened", error)
                    }
                }
            } label: {
                if self.accountStore.saving {
                    ProgressView()
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.green)
                        .cornerRadius(15.0)
                } else {
                    Text("Confirm Phone")
                        .asPrimaryButton()
                        .opacity(self.phoneVerificationCode.count != 6 ? 0.5 : 1.0)
                }
            }
            .disabled(self.phoneVerificationCode.count != 6 || self.accountStore.saving)
        }
        .padding()
        .disabled(self.accountStore.saving)
        .presentationDetents([.fraction(0.40)])
    }
}

struct PhoneVerifyButton_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        PhoneVerifyButton()
            .environmentObject(accountStore)
    }
}
