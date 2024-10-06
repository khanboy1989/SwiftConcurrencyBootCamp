//
//  AsyncStreamsBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 05/10/2024.
//

import SwiftUI


/*
 AsyncStreams are basically same thing as checkedContinuation
 except they return multiple pieces of data over time
 They are publisher & subscriber like Combine 
 */
class AsyncStreamDataManager {
    //AsyncStream accepts generic type data
    // That can return any kind of data but now we are supporting integer
    func getAsyncStream() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { [weak self] continuation in
            self?.getFakeData(newValue: {
                continuation.yield($0)
            }, onFinish: { error in
                continuation.finish(throwing: error)
            })
        }
    }
    
    // Simulate returning multiple items for different timing
    func getFakeData(newValue: @escaping (_ value: Int) -> Void, onFinish: @escaping (_ error: Error?) -> Void)  {
        let items: [Int] = [1,2,3,4,5,6,7,8,9,10]
        
        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item), execute: {
                newValue(item)
                print("NEW DATA: \(item)")
                if item == items.last {
                    onFinish(nil)
                }
            })
        }
    }
}

@MainActor
final class AsyncStreamBootcampViewModel: ObservableObject {
    let manager = AsyncStreamDataManager()
    @Published private(set) var currentNumber: Int = 0
    
    
    func onViewAppear() {
        
        let task = Task { // Lifecycle of this task is different than the manager.getAsyncStream() if we cancel this task manager Dispatch task won't be cancelled we have to be aware of this
            do {
                for try await value in manager.getAsyncStream() {
                    currentNumber = value
                }
            } catch {
                print(error)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            task.cancel() // this will cancel the task above and UI is not getting updated (we did not cancel the manager task)
            print("TASK CANCELLED")
        })
        
        /*
         NEW DATA: 1
         NEW DATA: 2
         NEW DATA: 3
         NEW DATA: 4
         TASK CANCELLED
         NEW DATA: 5
         NEW DATA: 6
         NEW DATA: 7
         NEW DATA: 8
         NEW DATA: 9
         NEW DATA: 10
         */
    }
    
    // This will demonstrate how to use some of the Higher-Order methods
    // In this example we are showing dropFirst() async algorithm method
    // Some of the algorith methods are not available but they are available as package
    // Here: https://github.com/apple/swift-async-algorithms
    func onViewApperTwo() {
        Task {
            do {
                for try await value in manager.getAsyncStream().dropFirst(2) { // Drops first two items and after updates the UI
                    currentNumber = value
                }
            } catch {
                print(error)
            }
        }
    }
}

struct AsyncStreamBootcamp: View {
    @StateObject private var viewModel = AsyncStreamBootcampViewModel()
    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear {
                viewModel.onViewApperTwo()
            }
    }
}

#Preview {
    AsyncStreamBootcamp()
}
