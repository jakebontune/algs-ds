#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVGraph.h"
#import "JVMutableSinglyLinkedList.h"
#import "JVTreeDictionarySet.h"

@implementation JVGraphConnection {
    id _initialNodeKey;
    id _terminalNodeKey;
    NSValue *_value;
    BOOL _directed;
}

#pragma mark - Creating a Graph Connection

+ (instancetype)connection {
    return [[JVGraphConnection alloc] init];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(NSValue *)value directed:(BOOL)isDirected {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:value directed:isDirected];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(NSValue *)value {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:value directed:NO];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey value:(NSValue *)value directed:(BOOL)isDirected {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:value directed:isDirected];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:nil directed:NO];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey directed:(BOOL)isDirected {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:nil directed:isDirected];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:nil directed:NO];
}

#pragma mark - Initializing a Graph Connection

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(NSValue *)value directed:(BOOL)isDirected {
    if(self = [super init]) {
        _initialNodeKey = initialNodeKey;
        _terminalNodeKey = terminalNodeKey;
        value = value;
        _directed = isDirected;
    }

    return self;
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(NSValue *)value {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:value directed:NO];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey value:(NSValue *)value directed:(BOOL)isDirected {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:value directed:isDirected];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:nil directed:NO];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey directed:(BOOL)isDirected; {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:nil directed:isDirected];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:nil directed:NO];
}

#pragma mark - Querying a Graph Connection

- (BOOL)isDirected {
    return _directed;
}

- (void)setDirected:(BOOL)isDirected {
    _directed = isDirected;
}

- (id)initialNodeKey {
    return _initialNodeKey;
}

- (void)setInitialNodeKey:(id)initialNodeKey {
    _initialNodeKey = initialNodeKey;
}

- (id)terminalNodeKey {
    return _terminalNodeKey;
}

- (void)setTerminalNodeKey:(id)terminalNodeKey {
    _terminalNodeKey = terminalNodeKey;
}

- (NSValue *)value {
    return _value;
}

- (void)setValue:(NSValue *)value {
    _value = value;
}

@end

// single node dictionary keys
static NSUInteger const kJV_GRAPH_NODE_INFO_DICTIONARY_CAPACITY = 3;
static NSString * const kJV_GRAPH_NODE_KEY_OBJECT = @"OBJECT";
static NSString * const kJV_GRAPH_NODE_KEY_INDEGREE = @"INDEGREE";
static NSString * const kJV_GRAPH_NODE_KEY_OUTDEGREE = @"OUTDEGREE";

// adjacent node dictionary keys
static NSUInteger const kJV_GRAPH_ADJACENT_NODE_DICTIONARY_CAPACITY = 4;
static NSString * const kJV_GRAPH_ADJACENT_NODE_KEY_ADJACENT_NODE = @"ADJACENT_NODE";
static NSString * const kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_ORIENTATION = @"CONNECTION_ORIENTATION";
static NSString * const kJV_GRAPH_ADJACENT_NODE_KEY_VERTEX_ORIENTATION = @"VERTEX_ORIENTATION";
static NSString * const kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_VALUE = @"CONNECTION_VALUE";

// default values
static int const kJV_GRAPH_DEFAULT_CONNECTION_VALUE = 1;

typedef NS_OPTIONS(NSUInteger, JVGraphConnectionOrientationOptions) {
    JVGraphConnectionOrientationDirected = 5 << 0, // 0000 0101
    JVGraphConnectionOrientationUndirected = 5 << 1, // 0000 1010
};

typedef NS_OPTIONS(NSUInteger, JVGraphVertexOrientationOptions) {
    JVGraphVertexOrientationInitial = 3 << 0, // 0000 0011
    JVGraphVertexOrientationTerminal = 3 << 2, // 0000 1100
};

@implementation JVGraph {
    NSMutableDictionary<id <NSCopying>, NSMutableDictionary *> *_nodeInfoDictionary;
    NSMutableDictionary<id <NSCopying>, JVMutableSinglyLinkedList<NSMutableDictionary *> *> *_adjacencyDictionary;
    NSUInteger _directedConnectionsCount;
    NSUInteger _undirectedConnectionsCount;
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
        _nodeInfoDictionary = [[NSMutableDictionary alloc] init];
        _adjacencyDictionary = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [self init]) {
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSMutableDictionary *singleNodeDictionary = [NSMutableDictionary dictionaryWithCapacity:kJV_GRAPH_NODE_INFO_DICTIONARY_CAPACITY];
            singleNodeDictionary[kJV_GRAPH_NODE_KEY_OBJECT] = obj;
            singleNodeDictionary[kJV_GRAPH_NODE_KEY_INDEGREE] = @(0);
            singleNodeDictionary[kJV_GRAPH_NODE_KEY_OUTDEGREE] = @(0);
            [_nodeInfoDictionary setObject:singleNodeDictionary forKey:key];
        }];
    }

    return self;
}

- (instancetype)initWithObject:(id)anObject forKey:(id)key {
    if(self = [self init]) {
        NSMutableDictionary *singleNodeDictionary = [NSMutableDictionary dictionaryWithCapacity:kJV_GRAPH_NODE_INFO_DICTIONARY_CAPACITY];
        singleNodeDictionary[kJV_GRAPH_NODE_KEY_OBJECT] = anObject;
        singleNodeDictionary[kJV_GRAPH_NODE_KEY_INDEGREE] = @(0);
        singleNodeDictionary[kJV_GRAPH_NODE_KEY_OUTDEGREE] = @(0);
        [_nodeInfoDictionary setObject:singleNodeDictionary forKey:key];
    }

    return self;
}

#pragma mark - Setting Objects

- (void)setObject:(id)anObject forKey:(id)key {
    NSMutableDictionary *singleNodeDictionary = [_nodeInfoDictionary objectForKey:key];
    if(singleNodeDictionary == nil) {
        singleNodeDictionary = [NSMutableDictionary dictionaryWithCapacity:kJV_GRAPH_NODE_INFO_DICTIONARY_CAPACITY];
        singleNodeDictionary[kJV_GRAPH_NODE_KEY_INDEGREE] = @(0);
        singleNodeDictionary[kJV_GRAPH_NODE_KEY_OUTDEGREE] = @(0);
    }

    singleNodeDictionary[kJV_GRAPH_NODE_KEY_OBJECT] = anObject;
}

#pragma mark - Removing Objects

- (void)removeObject:(id)anObject forKey:(id)key {
    JVMutableSinglyLinkedList *singleNodeAdjacencyList = [_adjacencyDictionary objectForKey:key];
    if(singleNodeAdjacencyList == nil) return;

    NSEnumerator *enumerator = [singleNodeAdjacencyList objectEnumerator];
    NSMutableDictionary *adjacentNodeDictionary;
    JVMutableSinglyLinkedList *adjacentNodeList;
    id adjacentNodeKey;
    NSMutableDictionary *adjacentNodeInfoDictionary;

    while((adjacentNodeDictionary = [enumerator nextObject]) != nil) {
        adjacentNodeKey = adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_ADJACENT_NODE];
        adjacentNodeList = [_adjacencyDictionary objectForKey:adjacentNodeKey];
        for(NSMutableDictionary *tempDictionary in [adjacentNodeList.objectEnumerator allObjects]) {
            if([tempDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_ADJACENT_NODE] isEqual:key]) {
                [adjacentNodeList removeObject:tempDictionary];
                adjacentNodeInfoDictionary = [_nodeInfoDictionary objectForKey:adjacentNodeKey];
                if(((NSNumber *)adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_VERTEX_ORIENTATION]).integerValue == JVGraphVertexOrientationInitial) {
                    adjacentNodeDictionary[kJV_GRAPH_NODE_KEY_OUTDEGREE] = @(((NSNumber *)adjacentNodeDictionary[kJV_GRAPH_NODE_KEY_OUTDEGREE]).integerValue - 1);

                } else {
                    adjacentNodeDictionary[kJV_GRAPH_NODE_KEY_INDEGREE] = @(((NSNumber *)adjacentNodeDictionary[kJV_GRAPH_NODE_KEY_INDEGREE]).integerValue - 1);
                }

                if(((NSNumber *)adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_ORIENTATION]).integerValue == JVGraphConnectionOrientationDirected) {
                    --_directedConnectionsCount;
                } else {
                    --_undirectedConnectionsCount;
                }

                break;
            }
        }
    }

    [_nodeInfoDictionary removeObjectForKey:key];
    [_adjacencyDictionary removeObjectForKey:key];
}

#pragma mark - Querying a Graph

- (NSUInteger)connectionsCount {
    return (_directedConnectionsCount + _undirectedConnectionsCount);
}

- (NSUInteger)directedConnectionsCount {
    return _directedConnectionsCount;
}

- (NSUInteger)objectsCount {
    return [_nodeInfoDictionary count];
}

- (NSUInteger)undirectedConnectionsCount {
    return _undirectedConnectionsCount;
}

#pragma mark - Establishing Connections

- (void)connectObjectWithKey:(id)fromKey toObjectWithKey:(id)toKey {
    [self connectObjectWithKey:fromKey toObjectWithKey:toKey value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE) directed:NO];
}

- (void)connectObjectWithKey:(id)fromKey toObjectWithKey:(id)toKey value:(NSValue *)value {
    [self connectObjectWithKey:fromKey toObjectWithKey:toKey value:value directed:NO];
}
- (void)connectObjectWithKey:(id)fromKey toObjectWithKey:(id)toKey directed:(BOOL)directed {
    [self connectObjectWithKey:fromKey toObjectWithKey:toKey value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE) directed:NO];
}

- (void)connectObjectWithKey:(id)fromKey toObjectWithKey:(id)toKey value:(NSValue *)value directed:(BOOL)directed {
    NSMutableDictionary *fromNodeInfo = _nodeInfoDictionary[fromKey];
    NSMutableDictionary *toNodeInfo = _nodeInfoDictionary[toKey];
    if((fromNodeInfo == nil) || (toNodeInfo == nil)) /* give warning */ return;

    JVMutableSinglyLinkedList *adjacencyList = _adjacencyDictionary[fromKey];
    NSMutableDictionary *adjacentNodeDictionary;
    JVGraphConnectionOrientationOptions connectionOrientation = directed ? JVGraphConnectionOrientationDirected : JVGraphConnectionOrientationUndirected;
    
    if(adjacencyList == nil) {
        adjacencyList = [JVMutableSinglyLinkedList list];
        _adjacencyDictionary[fromKey] = adjacencyList;
    }

    adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_ADJACENT_NODE] = toKey;
    adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_VALUE] = value;
    adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_VERTEX_ORIENTATION] = @(JVGraphVertexOrientationInitial);
    adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_ORIENTATION] = @(connectionOrientation);
    [adjacencyList addObject:[adjacentNodeDictionary copy]];

    adjacencyList = _adjacencyDictionary[toKey];
    if(adjacencyList == nil) {
        adjacencyList = [JVMutableSinglyLinkedList list];
        _adjacencyDictionary[toKey] = adjacencyList;
    }

    adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_ADJACENT_NODE] = fromKey;
    adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_VALUE] = value;
    adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_VERTEX_ORIENTATION] = @(JVGraphVertexOrientationTerminal);
    [adjacencyList addObject:adjacentNodeDictionary];

    fromNodeInfo[kJV_GRAPH_NODE_KEY_OUTDEGREE] = @(((NSNumber *)fromNodeInfo[kJV_GRAPH_NODE_KEY_OUTDEGREE]).integerValue + 1);
    toNodeInfo[kJV_GRAPH_NODE_KEY_INDEGREE] = @(((NSNumber *)toNodeInfo[kJV_GRAPH_NODE_KEY_INDEGREE]).integerValue + 1);
    
    directed ? ++_directedConnectionsCount : ++_undirectedConnectionsCount;
}

#pragma mark - Breaking Connections

- (void)disconnectObjectWithKey:(id)key1 fromObjectWithKey:(id)key2 {
    [self disconnectObjectWithKey:key1 fromObjectWithKey:key2 value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE) directed:NO];
}

- (void)disconnectObjectWithKey:(id)key1 fromObjectWithKey:(id)key2 value:(NSValue *)value {
    [self disconnectObjectWithKey:key1 fromObjectWithKey:key2 value:value directed:NO];
}

- (void)disconnectObjectWithKey:(id)key1 fromObjectWithKey:(id)key2 directed:(BOOL)directed {
    [self disconnectObjectWithKey:key1 fromObjectWithKey:key2 value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE) directed:directed];
}

- (void)disconnectObjectWithKey:(id)key1 fromObjectWithKey:(id)key2 value:(NSValue *)value directed:(BOOL)directed {
    NSMutableDictionary *nodeInfoA = _nodeInfoDictionary[key1];
    NSMutableDictionary *nodeInfoB = _nodeInfoDictionary[key2];
    if((nodeInfoA == nil) || (nodeInfoB == nil)) /* give warning */ return;
    JVGraphConnectionOrientationOptions connectionOrientation = directed ? JVGraphConnectionOrientationDirected : JVGraphConnectionOrientationUndirected;
    JVMutableSinglyLinkedList *adjacencyListA = _adjacencyDictionary[key1];
    JVMutableSinglyLinkedList *adjacencyListB = _adjacencyDictionary[key2];
    if((adjacencyListA == nil) || (adjacencyListB == nil)) /* give warning */ return;
    BOOL foundConnection = NO;
    for(NSMutableDictionary *adjacentNodeDictionary in [adjacencyListA.objectEnumerator allObjects]) {
        if(([adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_ADJACENT_NODE] isEqual:key2])
            && ([adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_VALUE] isEqualToValue:value])
            && (((NSNumber *)adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_ORIENTATION]).integerValue == connectionOrientation)) {
            [adjacencyListA removeObject:adjacentNodeDictionary];
            if(((NSNumber *)adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_VERTEX_ORIENTATION]).integerValue == JVGraphVertexOrientationInitial) {
                nodeInfoB[kJV_GRAPH_NODE_KEY_OUTDEGREE] = @(((NSNumber *)nodeInfoB[kJV_GRAPH_NODE_KEY_OUTDEGREE]).integerValue - 1);
            } else {
                nodeInfoB[kJV_GRAPH_NODE_KEY_INDEGREE] = @(((NSNumber *)nodeInfoB[kJV_GRAPH_NODE_KEY_INDEGREE]).integerValue - 1);
            }

            foundConnection = YES;
            break;
        }
    }

    if(foundConnection == NO) /* give error */ return;

    for(NSMutableDictionary *adjacentNodeDictionary in [adjacencyListB.objectEnumerator allObjects]) {
        if([adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_ADJACENT_NODE] isEqual:key1]
            && ([adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_VALUE] isEqualToValue:value])
            && (((NSNumber *)adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_CONNECTION_ORIENTATION]).integerValue == connectionOrientation)) {
            [adjacencyListB removeObject:adjacentNodeDictionary];
            if(((NSNumber *)adjacentNodeDictionary[kJV_GRAPH_ADJACENT_NODE_KEY_VERTEX_ORIENTATION]).integerValue == JVGraphVertexOrientationInitial) {
                nodeInfoA[kJV_GRAPH_NODE_KEY_OUTDEGREE] = @(((NSNumber *)nodeInfoA[kJV_GRAPH_NODE_KEY_OUTDEGREE]).integerValue - 1);
            } else {
                nodeInfoA[kJV_GRAPH_NODE_KEY_INDEGREE] = @(((NSNumber *)nodeInfoA[kJV_GRAPH_NODE_KEY_INDEGREE]).integerValue - 1);
            }

            break;
        }
    }

    directed ? --_directedConnectionsCount : --_undirectedConnectionsCount;
}



@end









