#import <Foundation/Foundation.h>

@interface JVBlockEnumerator<ObjectType> : NSEnumerator

- (NSArray<ObjectType> *)allObjects;
@property(nonatomic, strong) ObjectType (^block)(void);
+ (instancetype)enumeratorWithBlock:(ObjectType (^)(void))block;
- (instancetype)initWithBlock:(ObjectType (^)(void))block;
- (ObjectType)nextObject;

@end