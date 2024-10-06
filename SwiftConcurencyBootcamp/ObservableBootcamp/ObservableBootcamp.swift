//
//  ObservableBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 06/10/2024.
//

import SwiftUI

actor TitleDatabase {
    
    func newTitle() -> String {
        "Some new title!"
    }
}


@Observable class ObservableBootcampViewModel {
    @MainActor var title: String = "String Title!"
    @ObservationIgnored let database = TitleDatabase()
    
    // If we mark the variable title as mainactor
    // we get this error : Main actor-isolated property 'title' can not be mutated from a nonisolated context
    func updateTitle() async {
        let title = await database.newTitle()
        await MainActor.run(body: {
            self.title = title // Updates UI in main actor
            print("Current Thread =\(Thread.current)")
            //Current Thread =<_NSMainThread: 0x109500980>{number = 1, name = main}
        })
    }
}

struct ObservableBootcamp: View {
    @State private var viewModel = ObservableBootcampViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .task {
                await viewModel.updateTitle()
            }
    }
}
