#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVGraphConnectionStore.h"
#import "JVGraphConstants.h"

static NSString * const kCLASS_JVGraphAALAConnectionStore = @"JVGraphAALAConnectionStore";
static NSString * const kCLASS_JVGraphDLAConnectionStore = @"JVGraphDLAConnectionStore";
static NSString * const kCLASS_JVGraphAA2LAConnectionStore = @"JVGraphAA2LAConnectionStore";
static NSString * const kCLASS_JVGraphD2LAConnectionStore = @"JVGraphD2LAConnectionStore";

/* Store Representation change thresholds
** Threshold is based on benchmark tests from
** https://www.objc.io/issues/7-foundation/collections/
** Representation is chosen based on following formulas:
** |V| denotes the number of nodes
** |E| denotes the number of distinct connections
** AALA  - |V| <  THRESHOLD && |E| <  (2/3)|V|^2
** AA2LA - |V| <  THRESHOLD && |E| >= (2/3)|V|^2
** DLA 	 - |V| >= THRESHOLD && |E| <  (2/3)|V|^2
** D2LA  - |V| >= THRESHOLD && |E| >= (2/3)|V|^2
*/
static NSUInteger const kJV_GRAPH_CONNECTION_STORE_NUM_NODES_THRESHOLD = 500000; // 500,000

@implementation JVGraphConnectionStore {
@private
	id<JVGraphConnectionStoreProtocol> _store;
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

- (NSUInteger)nodeCount {
	return [_store nodeCount];
}

- (NSUInteger)outdegreeOfNode:(id)node {
	return [_store outdegreeOfNode:node];
}

- (NSUInteger)undirectedConnectionCount {
	return [_store undirectedConnectionCount];
}

- (NSUInteger)uniqueIncidenceCount {
  return [_store uniqueIncidenceCount];
}

@end