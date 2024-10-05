//
//  StrongSelfBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 24/09/2024.
//

import SwiftUI

// MARK: - DataManager
final class StrongSelfDataService {
    func getData() async -> String {
        return "Updated data!"
    }
}

// MARK: - ViewModel
final class StrongSelfBootcampViewModel: ObservableObject {
    @Published var data: String = "Some title!"
    let dataService =  StrongSelfDataService()
    
    private var someTask: Task<Void, Never>? = nil
    private var myTasks: [Task<Void, Never>] = []

    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
        myTasks.forEach({ $0.cancel() })
        myTasks = []
    }
    
    // This implies a strong reference...
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    // This implies a strong reference...
    func updateData2() {
        Task {
             self.data = await self.dataService.getData()
        }
    }
    
    // This implies a strong reference...
    func updateData3() {
        Task { [self] in // means hold a strong reference of the class in this closure
             self.data = await self.dataService.getData()
        }
    }
    
    // This implies a weak reference...
    func updateData4() {
        Task { [weak self] in // means hold a weak reference of the class in this closure
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    
    // We dont need to manage weak/strong
    // We can manage the Task!
    func updateData5() {
        someTask =  Task {
             self.data = await self.dataService.getData()
        }
    }
    
    /* Appends the tasks to myTasks array and when cancel is called
        it cancels all task that were appended into the array
     */
    func updateData6() {
        let task1 = Task {
            self.data = await self.dataService.getData()
        }
        
        myTasks.append(task1)
        
        let task2 = Task {
            self.data = await self.dataService.getData()
        }
        
        myTasks.append(task2)
    }
    
    // We delibaretly do not cancel tasks to keep strong references
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }
        
        Task.detached {
            self.data = await self.dataService.getData()
        }
    }
    
    // This implies a strong reference...
    func updateData8() async {
        self.data = await self.dataService.getData()
    }
}

struct StrongSelfBootcamp: View {
    
    @StateObject private var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }.onDisappear {
                viewModel.cancelTasks()
            }.task {
                await viewModel.updateData8() // This task is cancelled automatically since it is called within the task closure.
            }
    }
}

