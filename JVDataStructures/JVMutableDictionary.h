#import <Foundation/Foundation.h>

@interface JVMutableDictionary<KeyType, ObjectType> : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;
- (void)setObject:(ObjectType)anObject forKey:(KeyType)key;
- (void)removeObjectForKey:(KeyType)key;
- (ObjectType)objectForKey:(KeyType)key;
- (NSUInteger)count;
- (NSEnumerator<KeyType> *)keyEnumerator;

@end