//
//  AsyncLetBootCamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 21/04/2024.
//

import SwiftUI

struct AsyncLetBootCamp: View {
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!
    
    var body: some View {
        NavigationView{
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(images, id:\.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                    
                })
            }.navigationBarTitle("Async Let 🤓")
            .onAppear {
                Task {
                    do {
                        async let fetchImage1 = fetchImage()
//                        async let fetchTitle1 = fetchTitle() // fetches title and we can combine the types such as image, string, array
                        //let (image, title) = await (try fetchImage1, fetchTitle1)
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
//
//                        let (image1, image2, image3, image4) =  await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
//                        self.images.append(contentsOf: [image1, image2, image3, image4])

                        //They are all on same task but they will run serially so above example demostrates
                        //all async let will run same time and will wait each other to be completed

//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//                        
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//                        
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//                        
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)
                        
                    }catch {
                        print("error = \(error)")
                    }
                }
            }.background(.white)
        }
    }
    
    func fetchTitle() async -> String {
        return "NEW TITLE"
    }
    
    func fetchImage() async throws -> UIImage {
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

#Preview {
    AsyncLetBootCamp()
}



extension View {
    /// Sets the text color for a navigation bar title.
    /// - Parameter color: Color the title should be
    ///
    /// Supports both regular and large titles.
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
    
        // Set appearance for both normal and large sizes.
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
    
        return self
    }
}
