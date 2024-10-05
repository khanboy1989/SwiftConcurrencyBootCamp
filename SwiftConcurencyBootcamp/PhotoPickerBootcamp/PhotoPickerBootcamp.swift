//
//  PhotoPickerBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 05/10/2024.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotoPickerBootcampViewModel: ObservableObject {
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published private(set) var selectedImages: [UIImage] = []
    
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImagse(from: imageSelections)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            //Load Transferable:
            /*
             •    Purpose: It loads the content (image, video, or other data) of a PhotosPickerItem and returns the data in the type you specify.
             •    Asynchronous: The method is async, meaning it runs in a non-blocking manner. You can call it within a Task to load the selected data without freezing the app’s UI.
             •    Data Type: You pass a type parameter to loadTransferable, specifying what kind of data you want to load (e.g., Data.self for raw image data or other Transferable types).
             */
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                selectedImage = uiImage
            } catch {
                
            }
        }
    }
    
    
    // It will allow us to select multiple Images from the picker
    private func setImagse(from selections: [PhotosPickerItem]) {
        
        Task {
            var images: [UIImage] = []
            //Load Transferable:
            /*
             •    Purpose: It loads the content (image, video, or other data) of a PhotosPickerItem and returns the data in the type you specify.
             •    Asynchronous: The method is async, meaning it runs in a non-blocking manner. You can call it within a Task to load the selected data without freezing the app’s UI.
             •    Data Type: You pass a type parameter to loadTransferable, specifying what kind of data you want to load (e.g., Data.self for raw image data or other Transferable types).
             */
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
            
            selectedImages = images
        }
    }
}

struct PhotoPickerBootcamp: View {
    
    @StateObject private var viewModel = PhotoPickerBootcampViewModel()
    
    var body: some View {
        VStack(spacing: 40){
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }
            
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images, label: {
                Text("Open the photo picker!")
                    .foregroundStyle(.red)
            })
            
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                            
                        }
                    }
                }.padding()
            }
            
            PhotosPicker(selection: $viewModel.imageSelections, matching: .images, label: {
                Text("Open the photos picker!")
                    .foregroundStyle(.red)
            })
        }
    }
}

#Preview {
    PhotoPickerBootcamp()
}
