//
//  GlobalActorBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 02.05.24.
//

import SwiftUI

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three"]
    }
}

class GlobalActorBootcampViewModel: ObservableObject {
    @Published var dataArray = [String]()
    
    let manager = MyNewDataManager()
    
    func getData() async {
        
        //HEAVY COMPLEX METHODS 
        
        let data = await manager.getDataFromDatabase()
        self.dataArray = data
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
        }
    }
}

#Preview {
    GlobalActorBootcamp()
}

