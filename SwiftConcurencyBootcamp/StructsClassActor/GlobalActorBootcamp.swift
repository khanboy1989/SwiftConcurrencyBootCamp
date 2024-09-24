//
//  GlobalActorBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 02.05.24.
//

import SwiftUI

//Class or Struct
//Because we marked this as globalActor
// it will run the methods in global actor (kind of the different thread)
/*
 https://blog.devgenius.io/how-to-use-mainactor-and-globalactor-d5fd3794903d
 */
@globalActor struct MyFirstGlobalActor {
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four"]
    }
}

class GlobalActorBootcampViewModel: ObservableObject {
    @Published var dataArray = [String]()
    
    let manager = MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor
    func getData() {
        // HEAVY COMPLEX METHODS
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run(body: {
                self.dataArray = data
            })
        }
    }
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }.task {
            await viewModel.getData()
        }.onAppear {
            
        }
    }
}

#Preview {
    GlobalActorBootcamp()
}

