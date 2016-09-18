#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"
#import "JVGraphConstants.h"
#import "../JVMutableSinglyLinkedList.h"

static int const kAA2LA_NUM_CONNECTION_PROPERTIES = 3;
static int const kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION = 0;
static int const kAA2LA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION = 1;
static int const kAA2LA_CONNECTION_PROPERTIES_CONNECTION_VALUE = 2;

/****************************
** JVGraphAA2LAConnectionStore
** Array to store vertices; Array of adjacent Arrays of connections
** Lists of connection properties Arrays.
** An adjacency matrix implementation.
** Useful for graphs with a small amount of vertices and a great
** amount of connections.
*/
@interface JVGraphAA2LAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>



@end

@implementation JVGraphAA2LAConnectionStore {
	NSMutableArray *_degreeArray;
	NSUInteger _directedConnectionCount;
	NSUInteger _uniqueIncidenceCount;
	NSMutableArray *_indegreeArray;
	NSMutableArray *_nodeArray;
	NSMutableArray *_nodeMatrixArray;
	NSMutableArray *_outdegreeArray;
	NSUInteger _undirectedConnectionCount;
}

#pragma mark - Creating a Graph AA2LA Connection Store

+ (instancetype)store {
	return [[JVGraphAA2LAConnectionStore alloc] init];
}

+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2 {
    return [[JVGraphAA2LAConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:NO value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed {
    return [[JVGraphAA2LAConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:directed value:@(kJV_GRAPH_DEFAULT_CONNECTION_VALUE)];
}

+ (instancetype)storeWithNode:(id)node1
         	   adjacentToNode:(id)node2
           			 directed:(BOOL)directed
            		    value:(NSValue *)value {
    return [[JVGraphAA2LAConnectionStore alloc] initWithNode:node1 adjacentToNode:node2 directed:directed value:value];
}

#pragma mark - Initializing a Graph AA2LA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_degreeArray = [NSMutableArray array];
		_indegreeArray = [NSMutableArray array];
		_nodeArray = [NSMutableArray array];
		_nodeMatrixArray = [NSMutableArray array];
		_outdegreeArray = [NSMutableArray array];
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
    if(self = [self init]) {
	    [self setNode:node1 adjacentToNode:node2 directed:directed value:value];
	}

	return self;
}

#pragma mark - Adding to a Graph AA2LA Connection Store

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
    NSMutableArray *adjacencyArray;
    JVMutableSinglyLinkedList *connectionList;
	NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:kAA2LA_NUM_CONNECTION_PROPERTIES];
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

    propertyArray[kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION] = @(nodeOrientation);
    propertyArray[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] = @(connectionOrientation);
    propertyArray[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_VALUE] = value;

    if((indexSet.count == 0) && [node1 isEqual:node2]) { // new self loop
    	adjacencyArray = [NSMutableArray array];
    	connectionList = [JVMutableSinglyLinkedList list];

    	// Inform all other vertices that they have a potential neighbor
    	// Set all the vertices as potential neighbors to the new node
    	for(NSMutableArray *potentialNeighborAdjacencyArray in _nodeMatrixArray) {
    		[potentialNeighborAdjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    		[adjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    	}
    	// one more for itself
    	[connectionList addObject:[NSArray arrayWithArray:propertyArray]];
    	[adjacencyArray addObject:[connectionList copy]];

    	[_nodeMatrixArray addObject:adjacencyArray];

    	[_nodeArray addObject:node2];
    	[_degreeArray addObject:@(kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE)]; // self loops contribute two degrees

    	if(directed) {
	    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];
	    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];
	    } else {
	    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
	    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
	    }

	    ++_uniqueIncidenceCount;
    } else if(indexSet.count == 0) { // insert new nodes
	    // Order matters! The rule is to deal with the initial node
	    // first.
	    adjacencyArray = [NSMutableArray array];

    	// Inform all other vertices that they have two potential neighbors
    	// Set all the vertices as potential neighbors to the new nodes
    	for(NSMutableArray *potentialNeighborAdjacencyArray in _nodeMatrixArray) {
    		// Remember, node2 then node1.
    		[potentialNeighborAdjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    		[potentialNeighborAdjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    		[adjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    	}
    	// two more for the new nodes
    	[adjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    	[adjacencyArray addObject:[JVMutableSinglyLinkedList list]];

    	// node2 index is now ([array count] - 2)
    	// node1 index is now ([array count] - 1)

    	// Add to the list at (node2Index, node1Index)
    	connectionList = [adjacencyArray objectAtIndex:([adjacencyArray count] - 1)];
    	[connectionList addObject:[NSArray arrayWithArray:propertyArray]];

    	[_nodeMatrixArray addObject:[NSMutableArray arrayWithArray:adjacencyArray]];

	    [_nodeArray addObject:node2];
	    [_degreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

	    // set up for node1
	    [connectionList removeFirstObject];

	    nodeOrientation = JVGraphNodeOrientationTerminal;
	    propertyArray[kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION] = @(nodeOrientation);

	    // Add to the list at position (node1Index, node2Index)
	    connectionList = [adjacencyArray objectAtIndex:([adjacencyArray count] - 2)];
    	[connectionList addObject:[NSArray arrayWithArray:propertyArray]];

    	[_nodeMatrixArray addObject:[NSMutableArray arrayWithArray:adjacencyArray]];

	    [_nodeArray addObject:node1];
	    [_degreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

	    if(directed) {
	    	// node 2 contributes outdegree
	    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
	    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

	    	// node 1 contributes indegree
	    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];
	    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
	    } else {
	    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
	    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];

	    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
	    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
	    }

	    ++_uniqueIncidenceCount;
    } else if((indexSet.count == 1) && ![node1 isEqual:node2]) { // Only one of them exists.
    	adjacencyArray = [NSMutableArray array];
    	connectionList = [JVMutableSinglyLinkedList list];

    	// Inform all other vertices that they have a potential neighbor
    	// Set all the vertices as potential neighbors to the new node
    	for(NSMutableArray *potentialNeighborAdjacencyArray in _nodeMatrixArray) {
    		[potentialNeighborAdjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    		[adjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    	}
    	// one more for itself
    	[adjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    	[_nodeMatrixArray addObject:[NSMutableArray arrayWithArray:adjacencyArray]];

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
    		// Add the list to the position node1Index in the array
	    	[connectionList addObject:[NSArray arrayWithArray:propertyArray]];
	    	adjacencyArray = [_nodeMatrixArray lastObject];
	    	adjacencyArray[node1Index] = [connectionList copy];

    		[_nodeArray addObject:node2];
    		[_degreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

    		// set up for node1
    		// Get the list at position (node1Index, node2Index)
    		adjacencyArray = [_nodeMatrixArray objectAtIndex:node1Index];
    		connectionList = [adjacencyArray lastObject];

    		nodeOrientation = JVGraphNodeOrientationTerminal;
    		propertyArray[kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION] = @(nodeOrientation);

		    [connectionList addObject:[NSArray arrayWithArray:propertyArray]];

		    [self incrementDegreeAtNodeIndex:node1Index];

		    if(directed) {
		    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
		    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

		    	[self incrementIndegreeAtNodeIndex:node1Index];
		    }
    	} else {
    		// Get the list at position (node2Index, node1Index)
    		adjacencyArray = [_nodeMatrixArray objectAtIndex:node2Index];
    		connectionList = [adjacencyArray lastObject];

    		[connectionList addObject:[NSArray arrayWithArray:propertyArray]];

    		[self incrementDegreeAtNodeIndex:node2Index];

		    // set up for node1
    		nodeOrientation = JVGraphNodeOrientationTerminal;
    		propertyArray[kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION] = @(nodeOrientation);

    		connectionList = [JVMutableSinglyLinkedList list];

    		[connectionList addObject:[NSArray arrayWithArray:propertyArray]];
    		adjacencyArray = [_nodeMatrixArray lastObject];
	    	[adjacencyArray addObject:[connectionList copy]];

	    	[_nodeArray addObject:node1];
    		[_degreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

    		if(directed) {
    			[self incrementOutdegreeAtNodeIndex:node2Index];

		    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];
		    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
		    }
    	}

    	++_uniqueIncidenceCount;
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

    	adjacencyArray = [_nodeMatrixArray objectAtIndex:node2Index];
    	connectionList = [adjacencyArray objectAtIndex:node1Index];
    	[connectionList addObject:[NSArray arrayWithArray:propertyArray]];

    	adjacencyArray = [_nodeMatrixArray objectAtIndex:node1Index];
    	connectionList = [adjacencyArray objectAtIndex:node2Index];

    	nodeOrientation = JVGraphNodeOrientationTerminal;
        propertyArray[kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION] = @(nodeOrientation);
        propertyArray[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] = @(connectionOrientation);
        propertyArray[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_VALUE] = value;

	    [connectionList addObject:[NSArray arrayWithArray:propertyArray]];

	    [self incrementDegreeAtNodeIndex:node2Index];
	    [self incrementDegreeAtNodeIndex:node1Index];

	    if(directed) {
			[self incrementOutdegreeAtNodeIndex:node2Index];
			[self incrementIndegreeAtNodeIndex:node1Index];
	    }

	    if(connectionList.count == 1) ++_uniqueIncidenceCount;
    }
}

#pragma mark - Removing from a Graph AA2LA Connection Store

- (void)removeNode:(id)node {
	// Get the index of the node, if it exists
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
        NSUInteger idx;
    	JVMutableSinglyLinkedList *list;

    	// Get each node's adjacency array. Get the list in each array
    	// corresponding to the departing node's index. Go through the list and
    	// update degree counters at the current search node's index in the
    	// degree arrays. Remove the list associated with the departing node
    	// from the current search node's adjacency array.
    	for(NSMutableArray *adjacencyArray in _nodeMatrixArray) {
    		list = [adjacencyArray objectAtIndex:indexSet.firstIndex];
    		NSUInteger indegreeCount, outdegreeCount;

    		// We know the row is determined by idx and the 'column' is the
    		// departing node's index. So we simply need to check if the list
    		// at that position is occupied - if it is, we can safely say we
    		// are looking at a unique connection.
    		if(list.count != 0) --_uniqueIncidenceCount;

    		// The row node is the node at idx.
    		for(NSArray *propertyArray in list.objectEnumerator.allObjects) {
    			if([propertyArray[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqual:@(JVGraphConnectionOrientationDirected)]) {
    				if([propertyArray[kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION] isEqual:@(JVGraphNodeOrientationInitial)]) {
    					++outdegreeCount;
    				} else {
    					++indegreeCount;
    				}
                    --_directedConnectionCount;
    			} else {
    				--_undirectedConnectionCount;
    			}
    		}

    		[self updateDegreeAtNodeIndex:idx withAmount:-list.count];
    		[self updateIndegreeAtNodeIndex:idx withAmount:-indegreeCount];
    		[self updateOutdegreeAtNodeIndex:idx withAmount:-outdegreeCount];

    		++idx;

    		[adjacencyArray removeObjectAtIndex:indexSet.firstIndex];
    	}

    	[_nodeArray removeObjectAtIndex:indexSet.firstIndex];
	    [_degreeArray removeObjectAtIndex:indexSet.firstIndex];
	    [_indegreeArray removeObjectAtIndex:indexSet.firstIndex];
	    [_outdegreeArray removeObjectAtIndex:indexSet.firstIndex];
    }
}

- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value {
    NSUInteger node1Index, node2Index;
	JVMutableSinglyLinkedList *connectionList;
	NSMutableArray *adjacencyArray;
    BOOL foundMatch;
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1] || [obj isEqual:node2]);
    }];

    if((indexSet.count == 1) && [node1 isEqual:node2]) { // remove self loop
    	adjacencyArray = _nodeMatrixArray[indexSet.firstIndex];
    	connectionList = adjacencyArray[indexSet.firstIndex];

    	for(NSArray *propertyArray in connectionList.objectEnumerator.allObjects) {
    		if([self propertyArray:propertyArray matchesWithDirected:directed value:value]) {
    			[connectionList removeObject:propertyArray];
    			// self loops contribute two degrees
    			[self updateDegreeAtNodeIndex:indexSet.firstIndex withAmount:-2];
    			if(directed) {
    				[self decrementIndegreeAtNodeIndex:indexSet.firstIndex];
    				[self decrementOutdegreeAtNodeIndex:indexSet.firstIndex];
                    --_directedConnectionCount;
    			} else {
                    --_undirectedConnectionCount;
                }

    			if(connectionList.count == 0) --_uniqueIncidenceCount;
    			break;
    		}
    	}

    	return;
    } else if((indexSet.count == 2)) {
    	if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node2]) {
    		node2Index = indexSet.firstIndex;
    		node1Index = indexSet.lastIndex;
    	} else {
    		node2Index = indexSet.lastIndex;
    		node1Index = indexSet.firstIndex;
    	}

    	adjacencyArray = _nodeMatrixArray[node2Index];
    	connectionList = adjacencyArray[node1Index];

    	for(NSArray *propertyArray in connectionList.objectEnumerator.allObjects) {
    		if([self propertyArray:propertyArray matchesWithDirected:directed value:value] && (foundMatch == NO)) {
    			foundMatch = YES;
    			[connectionList removeObject:propertyArray];
    			[self decrementDegreeAtNodeIndex:node2Index];
    			[self decrementDegreeAtNodeIndex:node1Index];
    			if(directed) {
	    			if([propertyArray[kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) {
	    				[self decrementOutdegreeAtNodeIndex:node2Index];
	    				[self decrementIndegreeAtNodeIndex:node1Index];
	    			} else {
	    				[self decrementIndegreeAtNodeIndex:node2Index];
	    				[self decrementOutdegreeAtNodeIndex:node1Index];
	    			}
	    			--_directedConnectionCount;
    			} else {
	    			--_undirectedConnectionCount;
	    		}

    			if(connectionList.count == 0) --_uniqueIncidenceCount;
    		}
    	}
    } else {
    	return;
    }

    if(foundMatch == NO) return;

    adjacencyArray = _nodeMatrixArray[node1Index];
	connectionList = adjacencyArray[node2Index];

	for(NSArray *propertyArray in connectionList.objectEnumerator.allObjects) {
		if([self propertyArray:propertyArray matchesWithDirected:directed value:value]) {
			[connectionList removeObject:propertyArray];
			break;
		}
	}
}

#pragma mark - Querying a Graph AA2LA Connection Store

- (NSUInteger)connectionCount {
	return (_directedConnectionCount + _undirectedConnectionCount);
}

- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2
                        directed:(BOOL)directed
                           value:(NSValue *)value {
    NSUInteger node1Index, node2Index;
    NSArray *adjacencyArray;
	JVMutableSinglyLinkedList *connectionList;
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1] || [obj isEqual:node2]);
    }];

    if((indexSet.count == 2) || ((indexSet.count == 1) && ([node1 isEqual:node2]))) {
    	if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node1]) {
			node1Index = indexSet.firstIndex;
			node2Index = indexSet.lastIndex;
		} else {
			node1Index = indexSet.lastIndex;
			node2Index = indexSet.firstIndex;
		}

    	adjacencyArray = _nodeMatrixArray[node1Index];
	    connectionList = adjacencyArray[node2Index];
    	for(NSArray *propertyArray in connectionList.objectEnumerator.allObjects) {
    		if([self propertyArray:propertyArray matchesWithDirected:directed value:value]) {
    			if(directed) {
    				if([propertyArray[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqual:@(JVGraphConnectionOrientationDirected)] && [propertyArray[kAA2LA_CONNECTION_PROPERTIES_ROW_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) {
	    				return YES;
	    			}
    			} else {
    				if([propertyArray[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqual:@(JVGraphConnectionOrientationUndirected)]) {
	    				return YES;
	    			}
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

- (NSUInteger)uniqueIncidenceCount {
	return _uniqueIncidenceCount;
}

- (NSNumber *)indegreeOfNode:(id)node {
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	return [_indegreeArray objectAtIndex:indexSet.firstIndex];
    }

    return nil;
}

- (NSUInteger)nodeCount {
	return [_nodeArray count];
}

- (NSNumber *)outdegreeOfNode:(id)node {
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	return [_outdegreeArray objectAtIndex:indexSet.firstIndex];
    }

    return nil;
}

- (NSUInteger)undirectedConnectionCount {
	return _undirectedConnectionCount;
}

#pragma mark - Private Methods

- (BOOL)propertyArray:(NSArray *)array matchesWithDirected:(BOOL)directed value:(NSValue *)value {
	JVGraphConnectionOrientationOptions connectionOrientation;
	if(directed) {
		connectionOrientation = JVGraphConnectionOrientationDirected;
	} else {
		connectionOrientation = JVGraphConnectionOrientationUndirected;
	}

	return [array[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqual:@(connectionOrientation)] && [array[kAA2LA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value];
}


#pragma mark - Private Node Properties Accessor Methods

- (void)decrementDegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_degreeArray[nodeIndex] = @(((NSNumber *)_degreeArray[nodeIndex]).integerValue - 1);
}

- (void)decrementIndegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_indegreeArray[nodeIndex] = @(((NSNumber *)_indegreeArray[nodeIndex]).integerValue - 1);
}

- (void)decrementOutdegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_outdegreeArray[nodeIndex] = @(((NSNumber *)_outdegreeArray[nodeIndex]).integerValue - 1);
}

- (void)incrementDegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_degreeArray[nodeIndex] = @(((NSNumber *)_degreeArray[nodeIndex]).integerValue + 1);
}

- (void)incrementIndegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_indegreeArray[nodeIndex] = @(((NSNumber *)_indegreeArray[nodeIndex]).integerValue + 1);
}

- (void)incrementOutdegreeAtNodeIndex:(NSUInteger)nodeIndex {
	_outdegreeArray[nodeIndex] = @(((NSNumber *)_outdegreeArray[nodeIndex]).integerValue + 1);
}

- (void)updateDegreeAtNodeIndex:(NSUInteger)nodeIndex withAmount:(NSUInteger)amount {
	_degreeArray[nodeIndex] = @(((NSNumber *)_degreeArray[nodeIndex]).integerValue + amount);
}

- (void)updateIndegreeAtNodeIndex:(NSUInteger)nodeIndex withAmount:(NSUInteger)amount {
	_indegreeArray[nodeIndex] = @(((NSNumber *)_indegreeArray[nodeIndex]).integerValue + amount);
}

- (void)updateOutdegreeAtNodeIndex:(NSUInteger)nodeIndex withAmount:(NSUInteger)amount {
	_outdegreeArray[nodeIndex] = @(((NSNumber *)_outdegreeArray[nodeIndex]).integerValue + amount);
}

@end