//
//  TaskGroupBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 22/04/2024.
//

import SwiftUI

struct TaskGroupBootcamp: View {
    var body: some View {
        NavigationView {
            ScrollView {
//                LazyVGrid(columns: columns, content: {
//                    ForEach(images, id:\.self) { image in
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 150)
//                    }
//                    
//                })
            }.navigationBarTitle("Async Let 🤓")
            .task {
               
            }.background(.white)
        }
    }
}

#Preview {
    TaskGroupBootcamp()
}
