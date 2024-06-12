//
//  SendableBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 02/05/2024.
//

import SwiftUI

/*
 https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
 What if we have a actor and the non-thread safe class
 that are referenced from different places of our app
 we run to the issue we bring the sendable protocol to the table to use.
 */

actor CurrentUserManager {
    func updateDatabase(userInfo: MyClassUserInfo) {
    }
}

// we can safely send this type in to the concurrent code
//Classes are not thread safe and cannot inherit Sendable
/// A type whose values can safely be passed across concurrency domains by copying,
/// but which disables some safety checking at the conformance site.
struct MyUserInfo: Sendable {
    var name: String
}

//Classes are not thread safe and cannot inherit Sendable
//Non-final class 'MyClassUserInfo' cannot conform to 'Sendable'; use '@unchecked Sendable'
//Since we know that class does not have immutable value it can be sendable and thread safe
//if we add var name: String since they can be changed by other thread in that case we can inherit the sendable
//But it is not a good practice, because the classes are reference type
//also if we refer to use var name: String we can use @unchecked Sendable but still it is dangerous to use
// if we include let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
// in this case they would be thread safe and we can send it to thread to change the name so we can mark them @unchecked Sendable
final class MyClassUserInfo: @unchecked Sendable {
    var name : String
    
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
        
    }
}

class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyClassUserInfo(name: "info")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}
