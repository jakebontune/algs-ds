#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVGraphConnectionStore.h"
#import "JVGraphConstants.h"
#import "JVGraphConnectionAttributes.h"

static NSString * const kCLASS_JVGraphAALAConnectionStore = @"JVGraphAALAConnectionStore";
static NSString * const kCLASS_JVGraphDLAConnectionStore = @"JVGraphDLAConnectionStore";
static NSString * const kCLASS_JVGraphAA2LAConnectionStore = @"JVGraphAA2LAConnectionStore";
static NSString * const kCLASS_JVGraphD2LAConnectionStore = @"JVGraphD2LAConnectionStore";

@implementation JVGraphConnectionStore {
@private
	id<NSObject, JVGraphConnectionStoreProtocol> _store;
}

#pragma mark - Creating a Graph Connection Store

+ (instancetype)store {
	return [[JVGraphConnectionStore alloc] init];
}

+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2 {
    return [[JVGraphConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed {
    return [[JVGraphConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2 value:(NSValue *)value {
    return [[JVGraphConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

+ (instancetype)storeWithNode:(id)node1
         	   adjacentToNode:(id)node2
           			 directed:(BOOL)directed
            		    value:(NSValue *)value {
    return [[JVGraphConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:directed value:value];
}

#pragma mark - Initializing a Graph Connection Store

- (instancetype)init {
	if(self = [super init]) {
		Class JVGraphAALAConnectionStore = NSClassFromString(kCLASS_JVGraphAALAConnectionStore);
		_store = [[JVGraphAALAConnectionStore alloc] init];
	}

	return self;
}

- (instancetype)initWithNode:(id)node1 adjacentToNode:(id)node2 {
    return [self initWithNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (instancetype)initWithNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed {
    return [self initWithNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (instancetype)initWithNode:(id)node1 adjacentToNode:(id)node2 value:(NSValue *)value {
	return [self initWithNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (instancetype)initWithNode:(id)node1
              adjacentToNode:(id)node2
                    directed:(BOOL)directed
                       value:(NSValue *)value {
  if(self = [self init]) {
	    [_store setNode:node1 adjacentToNode:node2 directed:directed value:value];
  }

	return self;
}

#pragma mark - Adding to a Graph Connection Store

- (void)setNode:(id)node1 adjacentToNode:(id)node2 {
	[_store setNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)setNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed {
    [_store setNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)setNode:(id)node1 adjacentToNode:(id)node2 value:(NSValue *)value {
    [_store setNode:node1 adjacentToNode:node2 directed:NO value:value];
}

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
	[_store setNode:node1 adjacentToNode:node2 directed:directed value:value];
}

#pragma mark - Removing from a Graph Connection Store

- (void)removeNode:(id)node {
	[_store removeNode:node];
}

- (void)removeNode:(id)node1 adjacentToNode:(id)node2 {
    [_store removeNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)removeNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed {
    [_store removeNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)removeNode:(id)node1 adjacentToNode:(id)node2 value:(NSValue *)value {
    [_store removeNode:node1 adjacentToNode:node2 directed:NO value:value];
}

- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value {
    [_store removeNode:node1 adjacentToNode:node2 directed:directed value:value];
}

#pragma mark - Querying a Graph Connection Store

- (NSUInteger)connectionCount {
	return [_store connectionCount];
}

- (BOOL)connectionExistsFromNode:(id)node1 toNode:(id)node2 {
    return [_store connectionExistsFromNode:node1 toNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (BOOL)connectionExistsFromNode:(id)node1 toNode:(id)node2 directed:(BOOL)directed {
    return [_store connectionExistsFromNode:node1 toNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (BOOL)connectionExistsFromNode:(id)node1 toNode:(id)node2 value:(NSValue *)value {
    return [_store connectionExistsFromNode:node1 toNode:node2 directed:NO value:value];
}

- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2
                        directed:(BOOL)directed
                           value:(NSValue *)value {
    return [_store connectionExistsFromNode:node1 toNode:node2 directed:directed value:value];
}

- (NSUInteger)degreeOfNode:(id)node {
	return [_store degreeOfNode:node];
}

- (NSUInteger)directedConnectionCount {
	return [_store directedConnectionCount];
}

- (NSUInteger)indegreeOfNode:(id)node {
	return [_store indegreeOfNode:node];
}

- (NSUInteger)nodesConnectedCount {
	return [_store nodesConnectedCount];
}

- (NSUInteger)outdegreeOfNode:(id)node {
	return [_store outdegreeOfNode:node];
}

- (NSSet *)setOfNeighborsOfNode:(id)node {
    return [_store setOfNeighborsOfNode:node];
}

- (NSSet *)setOfNodesAdjacentFromNode:(id)node {
    return [_store setOfNodesAdjacentFromNode:node];
}

- (NSSet *)setOfNodesAdjacentToNode:(id)node {
    return [_store setOfNodesAdjacentToNode:node];
}

- (NSUInteger)undirectedConnectionCount {
	return [_store undirectedConnectionCount];
}

- (NSUInteger)uniqueConnectionCount {
    return [_store uniqueConnectionCount];
}

#pragma mark - Enumerating a Graph Connection Store

- (NSEnumerator *)adjacencyEnumerator {
    return _store.adjacencyEnumerator;
}

- (NSEnumerator *)nodeEnumerator {
    return _store.nodeEnumerator;
}

#pragma mark - Store Representation Conversions

- (void)useAA2LARepresentation {
    [self useRepresentationWithClassFromString:kCLASS_JVGraphAA2LAConnectionStore];
}

- (void)useAALARepresentation {
    [self useRepresentationWithClassFromString:kCLASS_JVGraphAALAConnectionStore];
}

- (void)useD2LARepresentation {
    [self useRepresentationWithClassFromString:kCLASS_JVGraphD2LAConnectionStore];
}

- (void)useDLARepresentation {
    [self useRepresentationWithClassFromString:kCLASS_JVGraphDLAConnectionStore];
}

#pragma mark - Private Methods

- (void)useRepresentationWithClassFromString:(NSString *)string {
    Class JVGraphChosenConnectionStore = NSClassFromString(string);

    if([_store isKindOfClass:JVGraphChosenConnectionStore]) return;

    id<NSObject, JVGraphConnectionStoreProtocol> store = [[JVGraphChosenConnectionStore alloc] init];
    NSArray *adjacencyArray = [_store adjacencyEnumerator].allObjects;
    id keyNode;
    for(NSDictionary *dictionary in adjacencyArray) {
        keyNode = [dictionary.objectEnumerator nextObject];
        for(JVGraphConnectionAttributes *connectionAttributes in dictionary[keyNode]) {
            if(connectionAttributes.isInitialNode) {
                [store setNode:connectionAttributes.adjacentNode adjacentToNode:keyNode directed:connectionAttributes.isDirected value:connectionAttributes.value];
            } else {
                [store setNode:keyNode adjacentToNode:connectionAttributes.adjacentNode directed:connectionAttributes.isDirected value:connectionAttributes.value];
            }
        }
    }

    _store = store;
}

@end