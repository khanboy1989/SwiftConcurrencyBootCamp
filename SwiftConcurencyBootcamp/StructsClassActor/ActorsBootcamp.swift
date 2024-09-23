//
//  ActorsBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 28/04/2024.
//

import SwiftUI

// 1. What is the problem that actors are solving
// 2. How was this problem solved prior to actors?
// 3. Actors can solve the problem!

/*
 The problem:
 
 ThreadSanitizer: Swift access race (pid=35898)
 Modifying access of Swift variable at 0x000109f5c350 by thread T2:
 #0 SwiftConcurencyBootcamp.MyDataManager.getRandomData() -> Swift.Optional<Swift.String> <null> (SwiftConcurencyBootcamp:arm64+0x100043f20)
 #1 closure #1 @Sendable () -> () in closure #2 (Foundation.Date) -> () in SwiftConcurencyBootcamp.BrowseView.body.getter : some <null> (SwiftConcurencyBootcamp:arm64+0x100047ee4)
 #2 partial apply forwarder for closure #1 @Sendable () -> () in closure #2 (Foundation.Date) -> () in SwiftConcurencyBootcamp.BrowseView.body.getter : some <null> (SwiftConcurencyBootcamp:arm64+0x10004a548)
 #3 reabstraction thunk helper from @escaping @callee_guaranteed @Sendable () -> () to @escaping @callee_unowned @convention(block) @Sendable () -> () <null> (SwiftConcurencyBootcamp:arm64+0x100046498)
 #4 __tsan::invoke_and_release_block(void*) <null> (libclang_rt.tsan_iossim_dynamic.dylib:arm64+0x77ee0)
 #5 _dispatch_client_callout <null> (libdispatch.dylib:arm64+0x5738)
 
 Previous modifying access of Swift variable at 0x000109f5c350 by thread T7:
 #0 SwiftConcurencyBootcamp.MyDataManager.getRandomData() -> Swift.Optional<Swift.String> <null> (SwiftConcurencyBootcamp:arm64+0x100043f20)
 #1 closure #1 @Sendable () -> () in closure #2 (Foundation.Date) -> () in SwiftConcurencyBootcamp.BrowseView.body.getter : some <null> (SwiftConcurencyBootcamp:arm64+0x100047ee4)
 #2 partial apply forwarder for closure #1 @Sendable () -> () in closure #2 (Foundation.Date) -> () in SwiftConcurencyBootcamp.BrowseView.body.getter : some <null> (SwiftConcurencyBootcamp:arm64+0x10004a548)
 #3 reabstraction thunk helper from @escaping @callee_guaranteed @Sendable () -> () to @escaping @callee_unowned @convention(block) @Sendable () -> () <null> (SwiftConcurencyBootcamp:arm64+0x100046498)
 #4 __tsan::invoke_and_release_block(void*) <null> (libclang_rt.tsan_iossim_dynamic.dylib:arm64+0x77ee0)
 #5 _dispatch_client_callout <null> (libdispatch.dylib:arm64+0x5738)
 
 
 how to solve make the MyDataManager thread safe by adding queue with
 private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
 
 it adds the queue to the getRandomData function so when it is called every request goes to the queue
 */
class MyDataManager {
    static let instance = MyDataManager()
    private init() {}
    var data: [String] = []
    
    // how we were solving thread safe issue before actors
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(completion: @escaping(_ title: String?) -> Void) {
        lock.async {
            self.data.append(UUID().uuidString)
            print("Current Thread = \(Thread.current)")
            completion(self.data.randomElement())
        }
    }
}

// Actors are thread safe
// Easy to read
// NO need to deal with locks
// In order to access something inside the actor we need to use await keyword
actor MyActorDataManager {
    static let instance = MyActorDataManager()
    private init() {}
    var data: [String] = []
    
    nonisolated let myrandomText = "Something"
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print("Current Thread = \(Thread.current)")
        return self.data.randomElement()
    }
    
    /*
     So every function or variable in actor if we need to access them we need to use the await keyword, it is just because of actors are async and every component inside the actors become async by defaut
     For whatever the reason if we want to avoid using await keyword (for example instance access needed for a function that returns only a string and we are not really worried about thread safety
     We should mark it as non-isoloated the function so it provides us the ability of using direct access to the func without using await keyword
     */
    nonisolated func getSavedDat() -> String {
        return "NEW DATA"
    }
}

struct HomeView: View {
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }.onReceive(timer, perform: { _ in
            let newString = manager.myrandomText
            
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData(completion: { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                })
//            }
        })
    }
}

struct BrowseView: View {
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }.onReceive(timer, perform: { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData(completion: { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                })
//            }
        })
    }
}

struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}


