//
//  MVVMBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 24/09/2024.
//

import SwiftUI

final class MyManagerClass {
    func getData() async throws -> String {
        return "Some Data Class"
    }
}

actor MyManagerActor {
    func getData() async throws -> String {
        return "Some Data Actor"
    }
}

@MainActor
final class MVVMBootcampViewModel: ObservableObject {
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    
    @MainActor @Published private(set) var myData: String = "Starting Text"
    
    private var tasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    func onCallToActionButtonPressed() {
        let task = Task {
            do {
//               myData = try await self.managerActor.getData()
                myData = try await self.managerClass.getData()
            } catch {
                print(error)
            }
        }
        tasks.append(task)
    }
    
    func onCallToActionButtonPressed2() {
        let task = Task {
            do {
//               myData = try await self.managerActor.getData()
                myData = try await self.managerActor.getData()
            } catch {
                print(error)
            }
        }
        tasks.append(task)
    }
}

struct MVVMBootcamp: View {
    @StateObject private var viewModel = MVVMBootcampViewModel()
    var body: some View {
        VStack {
            Text(viewModel.myData)
            Button("Click Me") {
                viewModel.onCallToActionButtonPressed()
            }
            
            Button("Click Me") {
                viewModel.onCallToActionButtonPressed2()
            }
        }.onDisappear {
            viewModel.cancelTasks()
        }
    }
}


