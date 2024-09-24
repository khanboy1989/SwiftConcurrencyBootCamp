//
//  MVVMBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 24/09/2024.
//

import SwiftUI

final class MyManagerClass {
    
}

actor MyManagerActor {
    
}

final class MVVMBootcampViewModel: ObservableObject {
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
}

struct MVVMBootcamp: View {
    @StateObject private var viewModel = MVVMBootcampViewModel()
    var body: some View {
        Text("Hello World!")
    }
}


