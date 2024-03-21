//
//  CancellableTaskBootcampView.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 21.03.24.
//

import SwiftUI

class CancellableTaskBootcampViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var image: UIImage? = nil
    @Published var showError: Bool = false
    private var task: Task<Void, Never>? = nil
    
    @MainActor
    func fetchImage() {
        task = Task {
            do {
                isLoading = true
                try await Task.sleep(nanoseconds: 5_000_000_000)
                try Task.checkCancellation()
                guard let url = URL(string: "https://picsum.photos/200") else { return }
                let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
                isLoading = false
                self.image = UIImage(data: data)
                print("IMAGE RETURNED SUCCESSFULLY!")
            }catch {
                isLoading = false
                self.showError = true
                print("error = \(error.localizedDescription)")
            }
        }
    }
    
    func cancelTask() {
        task?.cancel()
    }
}

struct CancellableTaskBootcampView: View {
    
    @StateObject private var viewModel = CancellableTaskBootcampViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } else {
                    Text("No Content To Show")
                }
            }
            Button("Download Image") {
                viewModel.fetchImage()
            }
            Button("Cancel Task") {
                viewModel.cancelTask()
            }
        }.task {
//            await viewModel.doSomeTask()
        }
        .alert(isPresented: $viewModel.showError, content: {
            Alert(title: Text("Error"), message: Text("Task Cancelled"))
        })
    }
}

#Preview {
    CancellableTaskBootcampView()
}
