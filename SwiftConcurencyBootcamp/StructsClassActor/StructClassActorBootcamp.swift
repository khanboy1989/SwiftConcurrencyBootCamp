//
//  StructClassActorBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 28/04/2024.
//

import SwiftUI

/*
 Links:
 - https://blog.onewayfirst.com/ios/post...
 - https://stackoverflow.com/questions/2...
 - https://stackoverflow.com/questions/2...
 - https://stackoverflow.com/questions/2...
 - https://stackoverflow.com/questions/2...
 - https://www.backblaze.com/blog/whats-...
 - https://medium.com/@vinayakkini/swift-basics-struct-vs-class-31b44ade28ae
 - https://medium.com/doyeona/automatic-reference-counting-in-swift-arc-weak-strong-unowned-925f802c1b99
 
 
 VALUE TYPES:
 - Structs, Enum, String, Int, etc.
 - Stored in the stack
 - Faster
 - Thread safe!
 - When you assign or pass value type a new copy of the value is created
 
 REFERENCE TYPES:
 - Class, Functions, Actor
 - Stored in the heap
 - Slower, but syncronized
 - Not thread safe because of heap memory
 - When you assign or pass reference type a new reference is created (pointer)
 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
 STACK:
 - Stores value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory very fast
 - Each thread has it's own stack

 
 HEAP:
 - Stores reference types
 - Shared accross threads
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 STRUCT:
 - Based on values
 - can be mutated
 - Stored in the stack

 
 CLASS:
 - Based on References (instances)
 - Stored in the heap!
 - Inherit from other classes
 
 
 ACTOR:
 - Same as Class but thread safe
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 When to use them:
 - Structs: Data Models, Views
 - Class: ViewModels
 - Actor: Shared 'Manager' and 'Data Store'
 */

actor StructClassActorBootcampManager {
    func getDataFromDatabase() {
        
    }
}

class StructClassActorBootcampViewModel: ObservableObject {
    @Published var title: String = ""
    
    init() {
        print("ViewModel INIT")
    }
}

struct StructClassActorBootcamp: View {
    
    @StateObject private var viewModel = StructClassActorBootcampViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
            .onAppear {
//                runTest()
            }
    }
}

struct StructClassActorBootcampHomeView: View {
    
    @State private var isActive: Bool = false
    
    var body: some View {
        StructClassActorBootcamp(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

extension StructClassActorBootcamp {
    
    private func runTest() {
        print("Test Started")
        structTest1()
        printDivider()
        classTest1()
        printDivider()
        actorTest1()
//        structTest2()
//        printDivider()
//        classTest2()
    }
    
    private func printDivider() {
        print("""
        - - - - - - - - - - - - - - - - - - - - - -
        """)
    }
    
    private func structTest1() {
        print("structTest1")
        let objectA = MyStruct(title: "Starting title!")
        print("objectA: ",objectA.title)
        
        
        print("Pass the VALUES of objectA to objectB")
        var objectB = objectA // distinct from objectA
        
        print("objectB: ",objectB.title)
        objectB.title = "Second title!"
        
        print("Object B title changed!")

        // only variable b changed because new complete struct completed when the objectA initialized to objectB
        print("objectA: ",objectA.title)
        print("objectB: ", objectB.title)
    }
    
    private func classTest1() {
        print("classTest1")
        let objectA = MyClass(title: "Starting title!")
        print("objectA: ",objectA.title)
        
        print("Pass the REFERENCE of objectA to objectB")
        let objectB = objectA // pointing same object
        print("objectB: ",objectB.title)
        
        objectB.title = "Second title!"
        
        print("Object B title changed!")

        print("objectA: ",objectA.title) // both variables title mutated because it is reference type
        print("objectB: ", objectB.title) // both variables title mutated because it is reference type
    }
    
    
    private func actorTest1() {
        
        Task {
            print("actorTest1")
            let objectA = MyActor(title: "Starting title!")
            await print("objectA: ",objectA.title)
            
            print("Pass the REFERENCE of objectA to objectB")
            let objectB = objectA // pointing same object
            await print("objectB: ",objectB.title)
            
            await objectB.updateTitle(newTitle: "Second title")
            print("Object B title changed!")

            await print("objectA: ",objectA.title)
            await print("objectB: ", objectB.title) 
            
        }
    }
       
}

struct MyStruct {
    var title: String
}


//Immutable Struct
struct CustomStruct {
    let title: String
    
    //generates totally new struct
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

struct MutatinStruct {
    private (set) var title: String

    init(title: String) {
        self.title = title
    }
    
    //changes the entire object not just the title
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorBootcamp {
   
    private func structTest2() {
        print("structTest2")
        
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title)
        
        struct1.title = "Title2"
        
        print("Struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)

        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("struct3: ", struct3.title)
        
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("struct3: ", struct3.title)

        var struct4 = MutatinStruct(title: "Title1")
        print("struct4: ", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("struct4: ", struct4.title)
    }
}


//Reference Type
class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    //changes the entire object not just the title
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    //changes the entire object not just the title
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorBootcamp {
    
    private func classTest2() {
        print("classTest2")
        
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)

        class1.title = "Title2"
        print("Class1: ", class1.title)

        
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)

        class2.updateTitle(newTitle: "Title2")
        print("Class2: ", class2.title)
        
    }
}
