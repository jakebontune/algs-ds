#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JVGraphTraversalOrder) {
	JVGraphBreadthFirstTraversalOrder,
	JVGraphDepthFirstTraversalOrder
};

@interface JVGraphConnection : NSObject

@property(getter=isDirected) BOOL directed;
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithInitialNodeKey:(nonnull id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey value:(nullable NSValue *)value directed:(BOOL)isDirected NS_DESIGNATED_INITIALIZER;
@property(nonnull, nonatomic, strong) id initialNodeKey;
@property(nullable, nonatomic, strong) id terminalNodeKey;
@property(nullable, nonatomic, strong) NSValue *value;

@end

@interface JVGraphConnection (JVExtendedGraphConnection)

// as you need

@end

@interface JVGraphConnection (JVGraphConnectionCreation)

+ (nonnull instancetype)connection;
+ (nonnull instancetype)connectionWithInitialNodeKey:(nonnull id)initialNodeKey;
+ (nonnull instancetype)connectionWithInitialNodeKey:(nonnull id)initialNodeKey directed:(BOOL)isDirected;
+ (nonnull instancetype)connectionWithInitialNodeKey:(nonnull id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey;
+ (nonnull instancetype)connectionWithInitialNodeKey:(nonnull id)initialNodeKey value:(nullable NSValue *)value directed:(BOOL)isDirected;
+ (nonnull instancetype)connectionWithInitialNodeKey:(nonnull id)initialNodeKey terminalNodeKey:(nonnull id)terminalNodeKey value:(nullable NSValue *)value;
+ (nonnull instancetype)connectionWithInitialNodeKey:(nonnull id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey value:(nullable NSValue *)value directed:(BOOL)isDirected;

- (nonnull instancetype)initWithInitialNodeKey:(nonnull id)initialNodeKey;
- (nonnull instancetype)initWithInitialNodeKey:(nonnull id)initialNodeKey directed:(BOOL)isDirected;
- (nonnull instancetype)initWithInitialNodeKey:(nonnull id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey;
- (nonnull instancetype)initWithInitialNodeKey:(nonnull id)initialNodeKey value:(nullable NSValue *)value directed:(BOOL)isDirected;
- (nonnull instancetype)initWithInitialNodeKey:(nonnull id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey value:(nullable NSValue *)value;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JVGraph<KeyType, ObjectType> : NSObject

- (BOOL)connectionExistsFromObjectWithKey:(KeyType)key1 toObjectWithKey:(KeyType)key2 withWeight:(NSNumber *)weight;
- (void)connectObjectWithKey:(KeyType)key1 toObjectWithKey:(KeyType)key2 directed:(BOOL)flag;
@property(readonly) NSUInteger objectsCount;
- (void)compressPaths;
@property(readonly) NSUInteger connectionsCount;
@property(readonly) NSUInteger directedConnectionsCount;
@property(readonly) NSUInteger undirectedConnectionsCount;
@property(readonly) NSUInteger outDegreeCount;
@property(readonly) NSUInteger inDegreeCount;
- (void)disconnectObjectWithKey:(KeyType)key1 fromObjectWithKey:(KeyType)key2 directed:(BOOL)flag;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
-(NSEnumerator<KeyType> *)keyEnumeratorUsingTraversalOrder:(JVGraphTraversalOrder)order;
- (nullable ObjectType)objectForKey:(KeyType)key;
- (void)removeObjectForKey:(KeyType)key;
- (void)setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)key;

@end

@interface JVGraph<KeyType, ObjectType> (JVExtendedGraph)

- (void)breakAllConnectionsBetweenObjectWithKey:(KeyType)key1 andObjectWithKey:(KeyType)key2;
- (void)connectObjectWithKey:(KeyType)key1 toObjectWithKey:(KeyType)key2 withWeight:(NSNumber *)weight directed:(BOOL)flag;
- (BOOL)containsObject:(ObjectType)anObject;
- (void)disconnectObjectWithKey:(KeyType)key1 fromObjectWithKey:(KeyType)key2 withWeight:(NSNumber *)weight directed:(BOOL)flag;
- (NSEnumerator<ObjectType> *)objectEnumeratorUsingTraversalOrder:(JVGraphTraversalOrder)order;
- (NSArray<ObjectType>*)objectsForKeys:(NSArray<KeyType> *)keys;
- (void)removeObjectForKeys:(NSArray<KeyType> *)keys;

@end

@interface JVGraph<KeyType, ObjectType> (JVGraphCreation)

+ (instancetype)graph;
+ (instancetype)graphWithDictionary:(NSDictionary<KeyType, ObjectType> *)dictionary;
+ (instancetype)graphWithObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)key;

- (instancetype)initWithDictionary:(NSDictionary<KeyType, ObjectType> *)dictionary;
- (instancetype)initWithObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)key;

@end

NS_ASSUME_NONNULL_END