//
//  OCPerson.m
//  swift-call-objectivec
//
//  Created by Ankui on 5/15/21.
//

#import "OCPerson.h"

@implementation OCPerson

- (instancetype)initWithAge:(NSInteger)age name:(NSString *)name {
    if (self = [super init]) {
        self.age = age;
        self.name = name;
    }
    return self;
}

+ (instancetype)personWithAge:(NSInteger)age name:(NSString *)name {
    return [[self alloc] initWithAge:age name:name];
}

- (void)run {
    NSLog(@"%s %zd %@", __func__, _age, _name);
}

+ (void)run {
    NSLog(@"%s", __func__);
}

- (void)eat:(NSString *)food other:(NSString *)other {
    NSLog(@"%s %zd %@ %@ %@", __func__, _age, _name, food, other);
}

+ (void)eat:(NSString *)food other:(NSString *)other {
    NSLog(@"%s %@ %@", __func__, food, other);
}

@end

int sum(int a, int b) {
    return a + b;
}
