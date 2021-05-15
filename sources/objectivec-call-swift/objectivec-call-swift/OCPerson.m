//
//  OCPerson.m
//  objectivec-call-swift
//
//  Created by Ankui on 5/15/21.
//

#import "OCPerson.h"
#import "objectivec_call_swift-Swift.h"

@implementation OCPerson

@end


void testSwift(void) {
    NSLog(@"%s", __func__);
    
//    Car *car = [[Car alloc] initWithPrice:1.85 band:@"Benz"];
//    [car run];
//    [car test];
//    [Car run];
    
    OCCar *car = [[OCCar alloc] initWithPrice:10.5 band:@"BMW"];
    car.price = 108.5;
    car.name = @"Bently";
    [car drive]; // 108.5 Bently run
//    [car exec:10 v2:20];
    [OCCar run]; // Car run
}
