//
//  Person.swift
//  objectivec-call-swift
//
//  Created by Ankui on 5/16/21.
//

import Foundation

@objcMembers class Person: NSObject {
    func test1(v1: Int) {
        print("test1")
    }
    
    func test2(v1: Int, v2: Int) {
        print("test2(v1:v2:)")
    }
    
    func test2(_ v1: Double, _ v2: Double) {
        print("test2(_:_:)")
    }
    
    func run() {
        perform(#selector(test1))
        perform(#selector(test1(v1:)))
        perform(#selector(test2(v1:v2:)))
        perform(#selector(test2(_:_:)))
        perform(#selector(test2 as (Double, Double) -> Void))
        
    }
}
