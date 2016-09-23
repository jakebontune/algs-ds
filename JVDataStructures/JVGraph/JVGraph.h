#import <Foundation/Foundation.h>
#import "JVGraphConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface JVGraph<KeyType, ObjectType> : NSObject

- (BOOL)connectionExistsFromObjectForKey:(ObjectType)fromKey toObjectWithKey:(ObjectType)toKey directed:(BOOL)directed value:(NSValue *)value;
- (void)connectObjectWithKey:(KeyType)key1 toObjectWithKey:(KeyType)key2 directed:(BOOL)flag value:(NSValue *)value;
@property(readonly) NSUInteger objectsCount;
- (void)compressPaths;
@property(readonly) NSUInteger connectionsCount;
@property(readonly) NSUInteger directedConnectionsCount;
@property(readonly) NSUInteger undirectedConnectionsCount;
@property(readonly) NSUInteger outDegreeCount;
@property(readonly) NSUInteger inDegreeCount;
- (void)disconnectObjectWithKey:(KeyType)key1 fromObjectWithKey:(KeyType)key2 directed:(BOOL)flag;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
-(NSEnumerator<KeyType> *)keyEnumeratorUsingTraversalOrder:(JVGraphTraversalOrder)order startWithObjectForKey:(KeyType)key;
- (nullable ObjectType)objectForKey:(KeyType)key;
- (void)removeObjectForKey:(KeyType)key;
- (void)setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)key;

@end

@interface JVGraph<KeyType, ObjectType> (JVExtendedGraph)

- (void)breakAllConnectionsBetweenObjectWithKey:(KeyType)key1 andObjectWithKey:(KeyType)key2;
- (BOOL)containsObject:(ObjectType)anObject;
- (void)disconnectObjectWithKey:(KeyType)key1 fromObjectWithKey:(KeyType)key2 withWeight:(NSNumber *)weight directed:(BOOL)flag;
- (NSEnumerator<ObjectType> *)objectEnumeratorUsingTraversalOrder:(JVGraphTraversalOrder)order;
- (ObjectType)objectForKeyedSubscript:(KeyType)key;
- (NSArray<ObjectType>*)objectsForKeys:(NSArray<KeyType> *)keys;
- (void)removeObjectForKeys:(NSArray<KeyType> *)keys;
- (void)setObject:(ObjectType)obj forKeyedSubscript:(KeyType <NSCopying>)key;

@end

@interface JVGraph<KeyType, ObjectType> (JVGraphCreation)

+ (instancetype)graph;
+ (instancetype)graphWithDictionary:(NSDictionary<KeyType, ObjectType> *)dictionary;
+ (instancetype)graphWithObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)key;

- (instancetype)initWithDictionary:(NSDictionary<KeyType, ObjectType> *)dictionary;
- (instancetype)initWithObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)key;

@end

NS_ASSUME_NONNULL_END