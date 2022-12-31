//
//  ConnectionDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionDetail: View {
    @ObservedObject var connectionStore: ConnectionStore
    
    @State var showSettings = false

    var body: some View {
        if self.connectionStore.loading == false && self.connectionStore.connection != nil {
            ScrollView {
                HStack {
                    Spacer()
                    Button {
                        self.showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .renderingMode(.template)
                            .foregroundColor(.black)
                    }
                    .padding([.trailing], 25)
                    .padding([.top], -25)
                }
    
                AsyncImage(url: URL(string: self.connectionStore.connection!.profileImage), content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 100, maxHeight: 100)
                        .clipShape(Circle())
                }, placeholder: {
                    ProgressView()
                        .padding(35)
                })
                
                if self.connectionStore.connection!.email != nil {
                    VStack(alignment: .leading) {
                        Text("Email")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        
                        Text(self.connectionStore.connection!.email!)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
                
                if self.connectionStore.connection!.phoneNumber != nil {
                    VStack(alignment: .leading) {
                        Text("Phone Number")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        Text(self.connectionStore.connection!.phoneNumber!)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
                
                if self.connectionStore.connection!.address != nil {
                    VStack(alignment: .leading) {
                        Text("Street Address")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        Text(self.connectionStore.connection!.address!.street!)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
                
                if self.connectionStore.connection!.birthday != nil {
                    VStack(alignment: .leading) {
                        Text("Birthday")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        Text(self.connectionStore.connection!.birthdayStr!)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
            }
            .navigationTitle("\(self.connectionStore.connection!.firstName) \(self.connectionStore.connection!.lastName)")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: self.$showSettings) {
                Text("You'll be able to update connection settings here")
            }
        } else  {
            ProgressView()
        }
    }
}

struct ConnectionDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let connectionStore = ConnectionStore(connection: modelData.connection)

    static var previews: some View {
        ConnectionDetail(connectionStore: connectionStore)
            .environmentObject(modelData)
    }
}
