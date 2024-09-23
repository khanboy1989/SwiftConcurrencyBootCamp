//
//  AnyPublisherBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 02/05/2024.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
}

struct AsyncPublisherBootcamp: View {
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.dataArray, id: \.self) {
                        Text($0)
                            .font(.headline)
                    }
                }
            }.navigationTitle("AsyncPublisherBootcamp")
                .task {
                    await viewModel.start()
                }
        }
        
    }
}

class AsyncPublisherBootcampViewModel: ObservableObject {
    //Means it should be in main actor
    @MainActor @Published var dataArray: [String] = []
    var cancellables = Set<AnyCancellable>()
    let manager = AsyncPublisherDataManager()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        
        /// Combine way of subscribing to publisher
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }.store(in: &cancellables)
        
        /// The elements produced by the publisher, as an asynchronous sequence.
        /// It is the asyc/await concurrent subscribing method
        /// Values parameter helps us to convert any @Published variable to async concurrent way
        Task { // 'async' in a function that does not support concurrenct that is why we added await value
            for await value in manager.$myData.values {
                await MainActor.run(body: {
                    self.dataArray = value
                })
            }
        }
    }
    
    func start() async {
        await manager.addData()
    }
}
