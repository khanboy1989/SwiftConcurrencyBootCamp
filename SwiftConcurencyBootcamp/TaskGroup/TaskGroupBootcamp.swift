//
//  TaskGroupBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 22/04/2024.
//

import SwiftUI

class TaskGroupBootcampDataManager {
    
    func fetcImagesWithAsynceLet() async throws -> [UIImage] {
        var images: [UIImage] = []
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/300")
        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
        images.append(contentsOf: [image1, image2, image3, image4])
        return images
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        ]
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images = [UIImage]()
            images.reserveCapacity(urlStrings.count)
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            return images
            
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        }catch let error {
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupBootcampDataManager()
    
    func getImages() async {
        if let images = try? await manager.fetcImagesWithAsynceLet() {
            await MainActor.run(body: { [weak self] in
                self?.images.append(contentsOf: images)
            })
            
        }
    }
    
    func getImagesForGroupTask() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            await MainActor.run(body: { [weak self] in
                self?.images.append(contentsOf: images)
            })
        }
    }
}

struct TaskGroupBootcamp: View {
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(viewModel.images, id:\.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                    
                })
            }.navigationBarTitle("Task Group 🤓")
                .task {
                    await viewModel.getImagesForGroupTask()
                }.background(.white)
        }
    }
}

#Preview {
    TaskGroupBootcamp()
}
