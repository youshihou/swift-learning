//
//  OCPerson.h
//  swift-call-objectivec
//
//  Created by Ankui on 5/15/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

int sum(int a, int b);

@interface OCPerson : NSObject
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *name;

- (instancetype)initWithAge:(NSInteger)age name:(NSString *)name;
+ (instancetype)personWithAge:(NSInteger)age name:(NSString *)name;
- (void)run;
+ (void)run;
- (void)eat:(NSString *)food other:(NSString *)other;
+ (void)eat:(NSString *)food other:(NSString *)other;

@end

NS_ASSUME_NONNULL_END
