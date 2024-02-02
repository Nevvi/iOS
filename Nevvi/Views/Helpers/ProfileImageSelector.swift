//
//  ProfileImageSelector.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/16/23.
//

import SwiftUI
import NukeUI
import Mantis


struct ImageCropper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: CropViewControllerDelegate {
        var parent: ImageCropper
        
        init(_ parent: ImageCropper) {
            self.parent = parent
        }
        
        func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            
            let resized = resizeImage(image: cropped, targetSize: CGSize(width: 1024, height: 1024))!
            parent.image = resized
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            parent.image = nil
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
            let size = image.size
            
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            
            let rect = CGRect(origin: .zero, size: newSize)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.cropViewConfig.cropShapeType = Mantis.CropShapeType.circle()
        let cropViewController = Mantis.cropViewController(image: image!,
                                                           config: config)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}


struct ProfileImageSelector: View {
    @EnvironmentObject var accountStore: AccountStore
    
    var height: CGFloat
    var width: CGFloat
    
    @State private var selectedImage: UIImage? = nil
    @State private var showPicker: Bool = false
    @State private var showCropper: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LazyImage(url: URL(string: self.accountStore.profileImage), resizingMode: .aspectFill)
                .frame(width: width, height: height)
                .background(.white)
                .clipShape(Circle())
                
            Image(systemName: "plus")
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .background(Color.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
        .opacity(self.accountStore.savingImage ? 0.5 : 1.0)
        .onTapGesture {
            if !self.accountStore.savingImage {
                self.showPicker = true
            }
        }
        .sheet(isPresented: self.$showPicker) {
            ImagePicker(callback: { (image: UIImage) in
                self.selectedImage = image
                self.showCropper = true
            }, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $showCropper, content: {
            ImageCropper(image: self.$selectedImage)
                .onDisappear(perform: {
                    if self.selectedImage != nil {
                        self.accountStore.uploadImage(image: self.selectedImage!) { (result: Result<User, Error>) in
                            switch result {
                            case .failure(let error):
                                print("Something bad happened", error)
                            case .success(_):
                                print("Success!")
                            }
                        }
                    }
                })
                .ignoresSafeArea()
        })
    }
}

struct ProfileImageSelector_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        ProfileImageSelector(height: 100, width: 100)
            .environmentObject(accountStore)
    }
}
