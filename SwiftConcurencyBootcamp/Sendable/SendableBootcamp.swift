//
//  SendableBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 02/05/2024.
//

import SwiftUI

// SENDABLE: IT IS NOTHING MORE THAN CAN WE SEND THIS SAFELY TO CONCURRENT CODE
/*
 Before we start we should understand that each thread has a stack but there shared heap
 (see StructClassActorBootCamp.swift file) accross all thread if two different threads
 tries to reach same object in the heap/ or the same class we can run into data races.
 
 Solution to that we should take that class and make thread-safe, more or less the
 thread-safe class is an actor. That solves our data race problem at face value.
 
 But problem than becomes what if we have another object in the heap that we are going to send in that actor
 
 so what if we have an actor that is thread safe but we still have a class that is not thread-safe than we might still have
 data race problem.
 
 SO THAT IS THE REASON WHY WE WILL USE THE SENDABLE PROTOCOL
 
 */

// MARK: IT IS IMPORTANT TO READ TEXT BELOW & ABOVE OF THIS LINE
/*
 https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
 What if we have a actor and the non-thread safe class
 that are referenced from different places of our app
 we run to the issue we bring the sendable protocol to the table to use.
 */

actor CurrentUserManager {
    func updateDatabase(userInfo: MyClassUserInfo) async {
        do {
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 second delay
            print("Database updated with user info: \(userInfo.name)")
        } catch {
            print("Failed to sleep: \(error)")
        }
    }
    
    // This will use the struct type for update
    func updateDatabase(userInfo: MyUserInfo) async {
        
    }
}

// we can safely send this type in to the concurrent code
// Classes are not thread safe and cannot inherit Sendable
/// A type whose values can safely be passed across concurrency domains by copying,
/// but which disables some safety checking at the conformance site.
struct MyUserInfo: Sendable {
    var name: String
}

// MARK: - Case If We Want to make thread-safe
//Classes are not thread safe and cannot inherit Sendable
//Non-final class 'MyClassUserInfo' cannot conform to 'Sendable'; we mark the class as final
//use '@unchecked Sendable' that means we are gonna hanlde the thread-safety
//Since we know that class does not have immutable value it can be sendable and thread safe
//if we add var name: String since they can be changed by other thread in that case we can inherit the sendable
//But it is not a good practice, because the classes are reference type
//also if we refer to use var name: String we can use @unchecked Sendable but still it is dangerous to use
// if we include let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
// in this case they would be thread safe and we can send it to thread to change the name so we can mark them @unchecked Sendable
final class MyClassUserInfo: @unchecked Sendable {
    // unchecked is telling the compiler you do not need to check the thread we are gonna handle it
    var name: String
    
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    // Updating the name without using DispatchQueue (not thread-safe)
    // ERROR: Data race in SwiftConcurencyBootcamp.MyClassUserInfo.updateName(name: Swift.String) -> () at 0x1080606f0
    // So it is not safe to update the name like this we have to use dispatch queue
    func updateName(name: String) {
        // queue.async {
        self.name = name
        //}
    }
    
    // Thread safe write access
    func updateNameTwo(name: String) {
        queue.async {
            self.name = name
        }
    }
    
    // Thread-safe read access
    func getName() -> String {
        return queue.sync {
            return self.name
        }
    }
    
}

class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    //    func updateCurrentUserInfo() async {
    //        let info = MyClassUserInfo(name: "info")
    //        await manager.updateDatabase(userInfo: info)
    //    }
    
    // This is for class implementation
    // Class Type Model Non-Thread-Safe Read & Write
    func updateCurrentUserInfo() async {
        let info = MyClassUserInfo(name: "Initial Name")
        
        // Running multiple tasks concurrently to simulate data rac
        // Note: this task will fail because it does not use dipatch queue
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    info.updateName(name: "Updated by Task \(i)")
                    print("Task \(i) updated the name to: \(info.name)")
                }
            }
        }
        
        // After concurrent tasks, attempt to send data to the actor
        await manager.updateDatabase(userInfo: info)
    }
    
    // Class Type Model Thread-Safe Read & Write
    func updateCurrentUserInfoTwo() async {
        let info = MyClassUserInfo(name: "Initial Name")
        
        // Running multiple tasks concurrently to simulate data race
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    info.updateNameTwo(name: "Updated by Task \(i)")
                    
                    // Use thread-safe getName() instead of directly accessing info.name
                    let updatedName = info.getName()
                    print("Task \(i) updated the name to: \(updatedName)")
                }
            }
        }
        
        // After concurrent tasks, attempt to send data to the actor
        await manager.updateDatabase(userInfo: info)
    }
    
    
}

struct SendableBootcamp: View {
    @StateObject private var viewModel = SendableBootcampViewModel()
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                //await viewModel.updateCurrentUserInfo()
                await viewModel.updateCurrentUserInfoTwo()
            }
    }
}
