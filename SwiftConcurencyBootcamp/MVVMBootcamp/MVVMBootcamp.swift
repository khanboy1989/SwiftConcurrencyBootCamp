//
//  MVVMBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 24/09/2024.
//

import SwiftUI

final class MVVMBootcampViewModel: ObservableObject {
    
}

struct MVVMBootcamp: View {
    @StateObject private var viewModel = MVVMBootcampViewModel() 
    var body: some View {
        Text("Hello World!")
    }
}


