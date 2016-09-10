#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"
#import "../JVMutableSinglyLinkedList.h"
#import "JVGraphConstants.h"

static int const kAALA_NUM_CONNECTION_PROPERTIES = 4;
static int const kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE = 0;
static int const kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION = 1;
static int const kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION = 2;
static int const kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE = 3;

/****************************
** JVGraphAALAConnectionStore
** An adjacency list implementation.
** Array to store vertices; Array of adjacency Lists of connection
** properties Arrays.
** Useful for graphs with a small amount of vertices and
** connections.
*/
@interface JVGraphAALAConnectionStore<NodeType> : NSObject<JVGraphConnectionStoreProtocol>



@end

@implementation JVGraphAALAConnectionStore {
	NSMutableArray<JVMutableSinglyLinkedList<NSMutableArray *> *> *_adjacencyArray;
	NSUInteger _connectionCount;
	NSMutableArray *_degreeArray;
	NSUInteger _directedConnectionCount;
	NSMutableArray *_inDegreeArray;
	NSMutableArray *_nodeArray;
	NSMutableArray *_outDegreeArray;
	NSUInteger _undirectedConnectionCount;
}

#pragma mark - Creating a Graph AALA Connection Store

+ (instancetype)store {
	return [[JVGraphAALAConnectionStore alloc] init];
}

+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2 {
    return [[JVGraphAALAConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed {
    return [[JVGraphAALAConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

+ (instancetype)storeWithNode:(id)node1
         	   adjacentToNode:(id)node2
           			 directed:(BOOL)directed
            		    value:(NSValue *)value {
    return [[JVGraphAALAConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:directed value:value];
}

#pragma mark - Initializing a Graph AALA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_nodeArray = [NSMutableArray array];
		_adjacencyArray = [NSMutableArray array];
		_degreeArray = [NSMutableArray array];
		_inDegreeArray = [NSMutableArray array];
		_outDegreeArray = [NSMutableArray array];
	}

	return self;
}

- (instancetype)initWithNode:(id)node1
              adjacentToNode:(id)node2 {
    return [self initWithNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (instancetype)initWithNode:(id)node1
              adjacentToNode:(id)node2
                    directed:(BOOL)directed {
    return [self initWithNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (instancetype)initWithNode:(id)node1
              adjacentToNode:(id)node2
                    directed:(BOOL)directed
                       value:(NSValue *)value {
    if(self = [super init]) {
	    [self setNode:node1 adjacentToNode:node2 directed:directed value:value];
	}

	return self;
}

#pragma mark - Adding to a Graph AALA Connection Store

- (void)setNode:(id)node1 adjacentToNode:(id)node2 {
	[self setNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)setNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed {
    [self setNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
    JVMutableSinglyLinkedList *connectionList;
	NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:kAALA_NUM_CONNECTION_PROPERTIES];
    JVGraphNodeOrientationOptions nodeOrientation = JVGraphNodeOrientationInitial;
	JVGraphConnectionOrientationOptions connectionOrientation;

    NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1] || [obj isEqual:node2]);
    }];

    if(directed) {
    	connectionOrientation = JVGraphConnectionOrientationDirected;
    	++_directedConnectionCount;
    } else {
    	connectionOrientation = JVGraphConnectionOrientationUndirected;
    	++_undirectedConnectionCount;
    }

    propertiesArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node1;
    propertiesArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);
    propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] = @(connectionOrientation);
    propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] = value;

    if(indexSet.count == 0) { // insert new nodes
	    // Order matters! The rule is to deal with the initial node
	    // first.
	    [_nodeArray addObject:node2];
	    [_degreeArray addObject:@(1)];

	    [_nodeArray addObject:node1];
	    [_degreeArray addObject:@(1)];

	    connectionList = [JVMutableSinglyLinkedList list];

	    [connectionList addObject:[NSArray arrayWithArray:propertiesArray]];
	    [_adjacencyArray addObject:[connectionList copy]];
	    [connectionList removeFirstObject];

	    nodeOrientation = JVGraphNodeOrientationTerminal;
	    propertiesArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
	    propertiesArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);

	    [connectionList addObject:[NSArray arrayWithArray:propertiesArray]];

	    [_adjacencyArray addObject:connectionList];

	    if(directed) {
	    	[_inDegreeArray addObject:@(kJV_GRAPH_ZERO_DEFAULT_VALUE)];
	    	[_outDegreeArray addObject:@(1)];

	    	[_inDegreeArray addObject:@(1)];
	    	[_outDegreeArray addObject:@(kJV_GRAPH_ZERO_DEFAULT_VALUE)];
	    } else {
	    	[_inDegreeArray addObject:@(kJV_GRAPH_ZERO_DEFAULT_VALUE)];
	    	[_outDegreeArray addObject:@(kJV_GRAPH_ZERO_DEFAULT_VALUE)];

	    	[_inDegreeArray addObject:@(kJV_GRAPH_ZERO_DEFAULT_VALUE)];
	    	[_outDegreeArray addObject:@(kJV_GRAPH_ZERO_DEFAULT_VALUE)];
	    }
    } else if((indexSet.count == 1) && ![node1 isEqual:node2]) { // Only one of them exists.
    	NSUInteger node1Index;
    	NSUInteger node2Index;

    	if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node2]) {
    		node2Index = indexSet.firstIndex;
    		node1Index = NSNotFound;
    	} else {
    		node2Index = NSNotFound;
    		node1Index = indexSet.firstIndex;
    	}

    	if(node2Index == NSNotFound) {
    		[_nodeArray addObject:node2];
    		[_degreeArray addObject:@(1)];

    		connectionList = [JVMutableSinglyLinkedList list];

    		[connectionList addObject:[NSArray arrayWithArray:propertiesArray]];
    		[_adjacencyArray addObject:connectionList];

    		// set up for node1
    		[self incrementDegreeAtNodeIndex:node1Index];
    		connectionList = [_adjacencyArray objectAtIndex:node1Index];

    		nodeOrientation = JVGraphNodeOrientationInitial;
    		propertiesArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
    		propertiesArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);

		    [connectionList addObject:[NSArray arrayWithArray:propertiesArray]];

		    if(directed) {
		    	[_inDegreeArray addObject:@(kJV_GRAPH_ZERO_DEFAULT_VALUE)];
		    	[_outDegreeArray addObject:@(1)];

		    	[self incrementInDegreeAtNodeIndex:node1Index];
		    }
    	} else {
    		[self incrementDegreeAtNodeIndex:node2Index];
    		connectionList = [_adjacencyArray objectAtIndex:node2Index];

		    [connectionList addObject:[NSArray arrayWithArray:propertiesArray]];

		    // set up for node1
    		[_nodeArray addObject:node1];
    		[_degreeArray addObject:@(1)];

    		connectionList = [JVMutableSinglyLinkedList list];

    		nodeOrientation = JVGraphNodeOrientationTerminal;
    		propertiesArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
    		propertiesArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);

    		[connectionList addObject:[NSArray arrayWithArray:propertiesArray]];
    		[_adjacencyArray addObject:connectionList];

    		if(directed) {
    			[self incrementOutDegreeAtNodeIndex:node2Index];

		    	[_inDegreeArray addObject:@(kJV_GRAPH_ZERO_DEFAULT_VALUE)];
		    	[_outDegreeArray addObject:@(1)];
		    }
    	}
	} else { // both exist
    	NSUInteger node1Index;
    	NSUInteger node2Index;

    	if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node2]) {
    		node2Index = indexSet.firstIndex;
    		node1Index = indexSet.lastIndex;
    	} else {
    		node2Index = indexSet.lastIndex;
    		node1Index = indexSet.firstIndex;
    	}

    	connectionList = [_adjacencyArray objectAtIndex:node2Index];
    	[connectionList addObject:[NSArray arrayWithArray:propertiesArray]];

    	connectionList = [_adjacencyArray objectAtIndex:node1Index];

    	nodeOrientation = JVGraphNodeOrientationTerminal;
	    [propertiesArray insertObject:node2 atIndex:kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE];
	    [propertiesArray insertObject:@(nodeOrientation) atIndex:kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION];
	    [propertiesArray insertObject:@(connectionOrientation) atIndex:kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION];
	    [propertiesArray insertObject:value atIndex:kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE];

	    [connectionList addObject:[NSArray arrayWithArray:propertiesArray]];

	    [self incrementDegreeAtNodeIndex:node2Index];
	    [self incrementDegreeAtNodeIndex:node1Index];

	    if(directed) {
			[self incrementOutDegreeAtNodeIndex:node2Index];
			[self incrementInDegreeAtNodeIndex:node1Index];
	    }
    }
}

#pragma mark - Removing from a Graph AALA Connection Store

- (void)removeNode:(id)node {
	// Get the index of the node, if it exists
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	__block JVMutableSinglyLinkedList *adjacentNodeList;
    	__block NSArray *allAdjacentNodes;
    	NSUInteger nodeIndex = indexSet.firstIndex;

    	// Remove the node from the node array
    	[_nodeArray removeObjectAtIndex:nodeIndex];

    	// Find other nodes that are adjacent to this node and
    	// remove delete all connections that involve this node.
    	indexSet = [_adjacencyArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id list, NSUInteger idx, BOOL *stop) {
    		if(idx != nodeIndex) { // Avoid self loops
    			adjacentNodeList = (JVMutableSinglyLinkedList *)list;
    			allAdjacentNodes = adjacentNodeList.objectEnumerator.allObjects;
		    	for(NSArray *propertiesArray in allAdjacentNodes) {
		    		if([propertiesArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node]) {
		    			[adjacentNodeList removeObject:propertiesArray];
		    			if([propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(JVGraphConnectionOrientationDirected)]) {
		    				[self decrementDegreeAtNodeIndex:idx];
		    				if([propertiesArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) {
		    					[self decrementInDegreeAtNodeIndex:idx];
		    				} else {
		    					[self decrementOutDegreeAtNodeIndex:idx];
		    				}
		    				--_directedConnectionCount;
		    			} else {
		    				--_undirectedConnectionCount;
		    			}
		    		}
		    	}
    		}
    		return NO;
	    }];

	    [_adjacencyArray removeObjectAtIndex:nodeIndex];
	    [_degreeArray removeObjectAtIndex:nodeIndex];
	    [_inDegreeArray removeObjectAtIndex:nodeIndex];
	    [_outDegreeArray removeObjectAtIndex:nodeIndex];
    }
}

- (void)removeNode:(id)node1 adjacentToNode:(id)node2 {
    [self removeNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)removeNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed {
    [self removeNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value {
    NSUInteger node1Index, node2Index;
    NSArray *allAdjacentNodes;
	JVMutableSinglyLinkedList *nodeAdjacencyList;
	JVGraphConnectionOrientationOptions connectionOrientation;
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1] || [obj isEqual:node2]);
    }];

    if(indexSet.count == 2) {
    	if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node2]) {
    		node2Index = indexSet.firstIndex;
    		node1Index = indexSet.lastIndex;
    	} else {
    		node2Index = indexSet.lastIndex;
    		node1Index = indexSet.firstIndex;
    	}

	    if(directed) {
	    	connectionOrientation = JVGraphConnectionOrientationDirected;
	    } else {
	    	connectionOrientation = JVGraphConnectionOrientationUndirected;
	    }

	    nodeAdjacencyList = [_adjacencyArray objectAtIndex:node2Index];
    	allAdjacentNodes = nodeAdjacencyList.objectEnumerator.allObjects;
    	for(NSArray *propertiesArray in allAdjacentNodes) {
    		if([propertiesArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node1] && [propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(connectionOrientation)] && [propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value]) {
    			[nodeAdjacencyList removeObject:propertiesArray];
    			if(directed) {
    				[self decrementDegreeAtNodeIndex:node2Index];
    				[self decrementDegreeAtNodeIndex:node1Index];
    				if([propertiesArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) {
    					[self decrementOutDegreeAtNodeIndex:node2Index];
    					[self decrementInDegreeAtNodeIndex:node1Index];
    				} else {
    					[self decrementInDegreeAtNodeIndex:node2Index];
    					[self decrementOutDegreeAtNodeIndex:node1Index];
    				}
    				--_directedConnectionCount;
    			} else {
    				--_undirectedConnectionCount;
    			}
    		}
    	}
    } else {
    	return;
    }

    // set up for node1
    nodeAdjacencyList = [_adjacencyArray objectAtIndex:node1Index];
	allAdjacentNodes = nodeAdjacencyList.objectEnumerator.allObjects;
	for(NSArray *propertiesArray in allAdjacentNodes) {
		if([propertiesArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node2] && [propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(connectionOrientation)] && [propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value]) {
			[nodeAdjacencyList removeObject:propertiesArray];
		}
	}
}

#pragma mark - Querying a Graph AALA Connection Store

- (NSUInteger)connectionCount {
	return (_directedConnectionCount + _undirectedConnectionCount);
}

- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2 {
    return [self connectionExistsFromNode:node1 toNode:node2 value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2
                           value:(NSValue *)value {
    NSUInteger node1Index, node2Index;
    NSArray *allAdjacentNodes;
	JVMutableSinglyLinkedList *nodeAdjacencyList;
	JVGraphConnectionOrientationOptions connectionOrientation;
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
	    nodeAdjacencyList = [_adjacencyArray objectAtIndex:indexSet.firstIndex];
    	allAdjacentNodes = nodeAdjacencyList.objectEnumerator.allObjects;
    	for(NSArray *propertiesArray in allAdjacentNodes) {
    		if([propertiesArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node2] && [propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value]) {
    			if([propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqual:@(JVGraphConnectionOrientationUndirected)] || ([propertiesArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqual:@(JVGraphConnectionOrientationDirected)] && [propertiesArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)])) {
    				return YES;
    			}
    		}
    	}
    }

    return NO;
}

- (NSNumber *)degreeOfNode:(id)node {
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	return [_degreeArray objectAtIndex:indexSet.firstIndex];
    }

    return nil;
}

- (NSUInteger)directedConnectionCount {
	return _directedConnectionCount;
}

- (NSNumber *)inDegreeOfNode:(id)node {
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	return [_inDegreeArray objectAtIndex:indexSet.firstIndex];
    }

    return nil;
}

- (NSNumber *)outDegreeOfNode:(id)node {
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	return [_outDegreeArray objectAtIndex:indexSet.firstIndex];
    }

    return nil;
}

- (NSUInteger)undirectedConnectionCount {
	return _undirectedConnectionCount;
}

#pragma mark - Private Node Properties Accessor Methods

- (void)decrementDegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_degreeArray[nodeIndex] = @(((NSNumber *)_degreeArray[nodeIndex]).integerValue - 1);
}

- (void)decrementInDegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_inDegreeArray[nodeIndex] = @(((NSNumber *)_inDegreeArray[nodeIndex]).integerValue - 1);
}

- (void)decrementOutDegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_outDegreeArray[nodeIndex] = @(((NSNumber *)_outDegreeArray[nodeIndex]).integerValue - 1);
}

- (void)incrementDegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_degreeArray[nodeIndex] = @(((NSNumber *)_degreeArray[nodeIndex]).integerValue + 1);
}

- (void)incrementInDegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_inDegreeArray[nodeIndex] = @(((NSNumber *)_inDegreeArray[nodeIndex]).integerValue + 1);
}

- (void)incrementOutDegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_outDegreeArray[nodeIndex] = @(((NSNumber *)_outDegreeArray[nodeIndex]).integerValue + 1);
}

@end