#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVGraph.h"
#import "../JVMutableSinglyLinkedList.h"
#import "../JVTreeDictionarySet.h"
#import "JVGraphConnectionStore.h"
#import "../JVQueue.h"
#import "../JVStack.h"
#import "../JVBlockEnumerator.h"


@implementation JVGraph {
    JVGraphConnectionStore *_connectionStore;
    JVTreeDictionarySet *_treeDictionarySet;
}

#pragma mark - Creating a Graph

+ (instancetype)graph {
    return [[JVGraph alloc] init];
}

+ (instancetype)graphWithDictionary:(NSDictionary *)dictionary {
    return [[JVGraph alloc] initWithDictionary:dictionary];
}

+ (instancetype)graphWithObject:(id)anObject forKey:(id)key {
    return [[JVGraph alloc] initWithObject:anObject forKey:key];
}

#pragma mark - Initializing a Graph

- (instancetype)init {
    if(self = [super init]) {
        _connectionStore = [JVGraphConnectionStore store];
        _treeDictionarySet = [JVTreeDictionarySet treeDictionarySet];
    }

    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [self init]) {
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            _treeDictionarySet[key] = obj;
        }];
    }

    return self;
}

- (instancetype)initWithObject:(id)anObject forKey:(id)key {
    if(self = [self init]) {
        _treeDictionarySet[key] = anObject;
    }

    return self;
}

#pragma mark - Adding Objects

- (void)setObject:(id)anObject forKey:(id)key {
    _treeDictionarySet[key] = anObject;
}

#pragma mark - Removing Objects

- (void)removeObjectForKey:(id)key {
    [_treeDictionarySet removeObjectForKey:key];
    [_connectionStore removeNode:key];
}

#pragma mark - Establishing Connections

- (void)connectObjectWithKey:(id)fromKey toObjectWithKey:(id)toKey {
    [self connectObjectWithKey:fromKey toObjectWithKey:toKey directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)connectObjectWithKey:(id)fromKey toObjectWithKey:(id)toKey value:(NSValue *)value {
    [self connectObjectWithKey:fromKey toObjectWithKey:toKey directed:NO value:value];
}
- (void)connectObjectWithKey:(id)fromKey toObjectWithKey:(id)toKey directed:(BOOL)directed {
    [self connectObjectWithKey:fromKey toObjectWithKey:toKey directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)connectObjectWithKey:(id)fromKey toObjectWithKey:(id)toKey directed:(BOOL)directed value:(NSValue *)value {
    if((_treeDictionarySet[fromKey] == nil) || (_treeDictionarySet[toKey] == nil)) return;
    [_treeDictionarySet joinObjectForKey:fromKey andObjectForKey:toKey];
    [_connectionStore setNode:toKey adjacentToNode:fromKey directed:directed value:value];
}

#pragma mark - Breaking Connections

- (void)disconnectObjectWithKey:(id)key1 fromObjectWithKey:(id)key2 {
    [self disconnectObjectWithKey:key1 fromObjectWithKey:key2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)disconnectObjectWithKey:(id)key1 fromObjectWithKey:(id)key2 value:(NSValue *)value {
    [self disconnectObjectWithKey:key1 fromObjectWithKey:key2 directed:NO value:value];
}

- (void)disconnectObjectWithKey:(id)key1 fromObjectWithKey:(id)key2 directed:(BOOL)directed {
    [self disconnectObjectWithKey:key1 fromObjectWithKey:key2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)disconnectObjectWithKey:(id)key1 fromObjectWithKey:(id)key2 directed:(BOOL)directed value:(NSValue *)value {
    if((_treeDictionarySet[key1] == nil) || (_treeDictionarySet[key2] == nil)) return;
    [_treeDictionarySet disjoinObjectForKey:key1 andObjectForKey:key2];
    [_connectionStore removeNode:key1 adjacentToNode:key2 directed:directed value:value];
}

#pragma mark - Querying a Graph

- (BOOL)isConnected {
    return (_treeDictionarySet.componentCount <= 1);
}

- (NSUInteger)connectionCount {
    return _connectionStore.connectionCount;
}

- (BOOL)connectionExistsFromObjectForKey:(id)fromKey toObjectWithKey:(id)toKey directed:(BOOL)directed value:(NSValue *)value {
    return [_connectionStore connectionExistsFromNode:fromKey toNode:toKey directed:directed value:value];
}

- (NSUInteger)count {
    return [_treeDictionarySet count];
}

- (NSUInteger)degreeOfObjectForKey:(id)key {
    return [_connectionStore degreeOfNode:key];
}

- (NSUInteger)directedConnectionCount {
    return _connectionStore.directedConnectionCount;
}

- (BOOL)hasEulerianPath {
    if(_treeDictionarySet.componentCount == 0) return NO;
    NSUInteger numberOfOddVertices;

    for(id node in _connectionStore.nodeEnumerator) {
        if(([_connectionStore indegreeOfNode:node] + [_connectionStore outdegreeOfNode:node]) % 2 != 0) {
            ++numberOfOddVertices;
            if(numberOfOddVertices > 2) return NO;
        }
    }

    if(numberOfOddVertices == 1) return NO;

    return YES;
}

- (BOOL)hasEulerianCycle {
    if((_treeDictionarySet.componentCount == 0) || (_treeDictionarySet.componentCount > 1)) return NO;

    for(id node in _connectionStore.nodeEnumerator) {
        if(([_connectionStore indegreeOfNode:node] + [_connectionStore outdegreeOfNode:node]) % 2 != 0) {
            return NO;
        }
    }

    return YES;
}

- (NSUInteger)indegreeOfObjectForKey:(id)key {
    return [_connectionStore indegreeOfNode:key];
}

- (NSUInteger)nodesConnectedCount {
    return [_connectionStore nodesConnectedCount];
}

- (id)objectForKey:(id)key {
    return _treeDictionarySet[key];
}

- (BOOL)objectForKeyIsIsolated:(id)key {
    return [self objectForKeyIsIsolated:key];
}

- (NSUInteger)outdegreeOfObjectForKey:(id)key {
    return [_connectionStore outdegreeOfNode:key];
}

- (BOOL)pathExistsBetweenObjectForKey:(id)key1 andObjectForKey:(id)key2 {
    return [_treeDictionarySet relationExistsBetweenObjectForKey:key1 andObjectForKey:key2];
}

- (NSSet *)setOfKeysAdjacentFromObjectForKey:(id)key {
    return [_connectionStore setOfNodesAdjacentFromNode:key];
}

- (NSSet *)setOfKeysAdjacentToObjectForKey:(id)key {
    return [_connectionStore setOfNodesAdjacentToNode:key];
}

- (NSSet *)setOfIsolatedKeys {
    return [_treeDictionarySet setOfIsolatedKeys];
}

- (NSSet *)setOfNeighborsOfObjectForKey:(id)key {
    return [_connectionStore setOfNeighborsOfNode:key];
}

- (NSUInteger)undirectedConnectionCount {
    return _connectionStore.undirectedConnectionCount;
}

#pragma mark - Enumerating a Graph

- (void)enumerateKeysAndObjectsUsingTraversalOrder:(JVGraphTraversalOrder)order block:(void(^)(id key, id obj, BOOL isIsolatedObject, BOOL *stop))block {

}

- (NSEnumerator *)keyEnumerator {
    return _treeDictionarySet.keyEnumerator;
}

- (NSEnumerator *)keyEnumeratorUsingTraversalOrder:(JVGraphTraversalOrder)order startWithObjectForKey:(id)key {
    if(order == JVGraphBreadthFirstTraversalOrder) {
        return [self breadthFirstKeyEnumeratorStartingWithObjectForKey:key];
    } else if(order == JVGraphDepthFirstTraversalOrder) {
        return [self depthFirstKeyEnumeratorStartingWithObjectForKey:key];
    } else {
        return _treeDictionarySet.keyEnumerator;
    }
}

- (NSEnumerator *)objectEnumerator {
    return _treeDictionarySet.objectEnumerator;
}

#pragma mark - Private Methods

- (NSEnumerator *)breadthFirstKeyEnumeratorStartingWithObjectForKey:(id)key {
    JVBlockEnumerator *enumerator = [[JVBlockEnumerator alloc] init];
    __block JVQueue *queue = [JVQueue queue];
    __block NSMutableDictionary *markedDictionary = [NSMutableDictionary dictionary];
    __block NSEnumerator *keyEnumerator = _treeDictionarySet.keyEnumerator;

    if(_treeDictionarySet[key] == nil) return [[JVBlockEnumerator alloc] init];

    enumerator.block = ^{
        [queue enqueue:key];
        return (id)nil;
    };

    return enumerator;
}

- (NSEnumerator *)depthFirstKeyEnumeratorStartingWithObjectForKey:(id)key {
    JVBlockEnumerator *enumerator = [[JVBlockEnumerator alloc] init];
    __block JVStack *stack = [JVStack stack];
    __block NSMutableDictionary *markedDictionary = [NSMutableDictionary dictionary];
    __block NSEnumerator *keyEnumerator = _treeDictionarySet.keyEnumerator;

    if(_treeDictionarySet[key] == nil) return [[JVBlockEnumerator alloc] init];

    enumerator.block = ^{
        return (id)nil;
    };

    return enumerator;
}

#pragma mark - Custom Keyed Subscripting

- (id)objectForKeyedSubscript:(id)key {
    return _treeDictionarySet[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    _treeDictionarySet[key] = obj;
}


@end









