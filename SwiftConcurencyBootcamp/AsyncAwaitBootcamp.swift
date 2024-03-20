//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 19/03/2024.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = [String]()
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let title2 = "Title2: \(Thread.current)"
            
            DispatchQueue.main.async {
                self.dataArray.append(title2)
                
                let title3 = "Titl3: \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1: \(Thread.current)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_0000)
        
        let author2 = "Author2: \(Thread.current)"
        self.dataArray.append(author2)
    }

}

struct AsyncAwaitBootcamp: View {
    @StateObject private var viewModel = AsyncAwaitBootcampViewModel()
    
    var body: some View {
        
        List {
            ForEach(viewModel.dataArray, id: \.self) { data  in
                Text(data)
            }
        }.background(Color.pink.ignoresSafeArea())
            .scrollContentBackground(.hidden)
        .onAppear {
//            viewModel.addTitle1()
//            viewModel.addTitle2()
            
            Task {
               await viewModel.addAuthor1()
            }
        }
        
        
    }
}

#Preview {
    AsyncAwaitBootcamp()
}
