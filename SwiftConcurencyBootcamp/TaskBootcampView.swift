//
//  TaskBootcampView.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 20/03/2024.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
           await MainActor.run(body: {
                self.image = UIImage(data: data)
            })
        }catch {
            print("error = \(error.localizedDescription)")
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)

            })
        }catch {
            print("error = \(error.localizedDescription)")
        }
    }
}

struct TaskBootcampView: View {
    @StateObject private var viewModel = TaskBootcampViewModel()
    
    var body: some View {
        VStack(spacing: 40){
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }.onAppear {
            Task {
               await viewModel.fetchImage()
            }
            Task {
                await viewModel.fetchImage2()
            }
        }
    }
}

#Preview {
    TaskBootcampView()
}
