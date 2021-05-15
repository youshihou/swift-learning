//
//  Car.swift
//  objectivec-call-swift
//
//  Created by Ankui on 5/15/21.
//

import Foundation

@objc(OCCar)
@objcMembers class Car: NSObject {
    var price: Double
    @objc(name)
    var band: String
    
    init(price: Double, band: String) {
        self.price = price
        self.band = band
    }
    
    @objc(drive)
    func run() {
        print(price, band, "run")
    }
    
    static func run() {
        print("Car run")
    }
}

extension Car {
//    @objc(exec:v2)
    func test() {
        print(price, band, "test")
    }
}
