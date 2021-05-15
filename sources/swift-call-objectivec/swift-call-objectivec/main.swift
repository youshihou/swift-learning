//
//  main.swift
//  swift-call-objectivec
//
//  Created by Ankui on 5/15/21.
//

import Foundation

func sum(_ a: Int, _ b: Int) -> Int {
    a - b
}



var p = OCPerson(age: 10, name: "Jack")
p.age = 18
p.name = "Rose"
p.run()
p.eat("Apple", other: "Orange")

OCPerson.run()
OCPerson.eat("Pizza", other: "Banana")


@_silgen_name("sum")
func swift_sum(_ v1: Int32, _ v2: Int32) -> Int32

print(sum(10, 20)) // - 10
print(swift_sum(10, 20)) // 30
