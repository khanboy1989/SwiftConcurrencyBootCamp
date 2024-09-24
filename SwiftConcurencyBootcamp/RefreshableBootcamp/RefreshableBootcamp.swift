//
//  RefreshableBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 24/09/2024.
//

import SwiftUI

final class RefreshableDataService {
    func getData() async throws -> [String] {
        try? await Task.sleep(nanoseconds: 5_000_000_000) // simulate real network call
        return ["Apple", "Orange", "Banana"].shuffled()
    }
}

@MainActor
final class RefreshableBootcampViewModel: ObservableObject {
    let manager = RefreshableDataService()
    @Published private(set) var items: [String] = []
    
    func loadData() async {
        do {
            items = try await self.manager.getData()
        } catch {
            print(error)
        }
    }
}

struct RefreshableBootcamp: View {
    @StateObject private var viewModel = RefreshableBootcampViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) {
                        Text($0)
                            .font(.headline)
                    }
                }
            }.refreshable { // this is async so that is way refreshable indicator will be shown until the real task is completed
                await viewModel.loadData()
            }
            .navigationTitle("Refreshable")
            .task {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    RefreshableBootcamp()
}
