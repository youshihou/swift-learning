//
//  Car.swift
//  objectivec-call-swift
//
//  Created by Ankui on 5/15/21.
//

import Foundation


@objcMembers class Car: NSObject {
    var price: Double
    var band: String
    
    init(price: Double, band: String) {
        self.price = price
        self.band = band
    }
    
    func run() {
        print(price, band, "run")
    }
    
    static func run() {
        print("Car run")
    }
}

extension Car {
    func test() {
        print(price, band, "test")
    }
}
