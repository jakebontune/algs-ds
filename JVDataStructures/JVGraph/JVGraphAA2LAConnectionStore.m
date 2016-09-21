#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"
#import "JVGraphConstants.h"
#import "../JVMutableSinglyLinkedList.h"
#import "JVGraphConnectionAttributes.h"
#import "JVGraphDegreeAttributes.h"

/****************************
** JVGraphAA2LAConnectionStore
** Array to store vertices; Array of adjacent Arrays of connections
** Lists of connection properties Arrays.
** An adjacency matrix implementation.
** Efficient with graphs with a small amount of vertices and a great
** amount of connections.
*/
@interface JVGraphAA2LAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>



@end

@implementation JVGraphAA2LAConnectionStore {
    NSMutableArray<JVGraphDegreeAttributes *> *_degreeInfoArray;
	NSUInteger _directedConnectionCount;
	NSMutableArray *_nodeArray;
	NSMutableArray *_nodeMatrixArray;
	NSUInteger _undirectedConnectionCount;
    NSUInteger _uniqueIncidenceCount;
}

#pragma mark - Initializing a Graph AA2LA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_degreeInfoArray = [NSMutableArray array];
		_nodeArray = [NSMutableArray array];
		_nodeMatrixArray = [NSMutableArray array];
	}

	return self;
}

#pragma mark - Adding to a Graph AA2LA Connection Store

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
    JVGraphConnectionAttributes *connectionAttributes;
    NSMutableArray *adjacencyArray;
    JVMutableSinglyLinkedList *connectionList;

    connectionAttributes = [JVGraphConnectionAttributes attributesWithAdjacentNode:node1 directed:directed initialNode:YES value:value];

    if(directed) {
        ++_directedConnectionCount;
    } else {
        ++_undirectedConnectionCount;
    }

    NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1] || [obj isEqual:node2]);
    }];

    if(indexSet.count == 2) { // not a self loop and both are preexisting nodes
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
        [connectionList addObject:[connectionAttributes copy]];

        // node1 setup
        adjacencyArray = [_nodeMatrixArray objectAtIndex:node1Index];
        connectionList = [adjacencyArray objectAtIndex:node2Index];

        connectionAttributes.adjacentNode = node2;
        connectionAttributes.initialNode = NO;

        [connectionList addObject:connectionAttributes];

        [self incrementDegreeAtNodeIndex:node2Index];
        [self incrementDegreeAtNodeIndex:node1Index];

        if(directed) {
            [self incrementOutdegreeAtNodeIndex:node2Index];
            [self incrementIndegreeAtNodeIndex:node1Index];
        }

        if(connectionList.count == 1) ++_uniqueIncidenceCount;
    } else if((indexSet.count == 1) && [node1 isEqual:node2]) { // self loop with preexisting node
        connectionList = _nodeMatrixArray[indexSet.firstIndex][indexSet.firstIndex];
        if(connectionList.count == 0) ++_uniqueIncidenceCount;

        [connectionList addObject:connectionAttributes];

        [self updateDegreeAtNodeIndex:indexSet.firstIndex withAmount:2]; // self loops contribute two degrees

        if(directed) {
            [self incrementOutdegreeAtNodeIndex:indexSet.firstIndex];
            [self incrementIndegreeAtNodeIndex:indexSet.firstIndex];
        }
    } else if((indexSet.count == 0) && [node1 isEqual:node2]) { // new self loop with new node
        JVGraphDegreeAttributes *degreeAttributes = [JVGraphDegreeAttributes attributes];
    	adjacencyArray = [NSMutableArray array];
    	connectionList = [JVMutableSinglyLinkedList list];

    	// Inform all other vertices that they have a potential neighbor
    	// Set all the vertices as potential neighbors to the new node
    	for(NSMutableArray *potentialNeighborAdjacencyArray in _nodeMatrixArray) {
    		[potentialNeighborAdjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    		[adjacencyArray addObject:[JVMutableSinglyLinkedList list]];
    	}
    	// one more for itself
    	[connectionList addObject:connectionAttributes];
    	[adjacencyArray addObject:connectionList];

    	[_nodeMatrixArray addObject:adjacencyArray];

    	[_nodeArray addObject:node2];

        degreeAttributes.degree = kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE; // self loops contribute two degrees
    	if(directed) {
            degreeAttributes.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
            degreeAttributes.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
	    }

        [_degreeInfoArray addObject:degreeAttributes];

	    ++_uniqueIncidenceCount;
    } else if((indexSet.count == 1) && ![node1 isEqual:node2]) { // Only one of them exists.
        JVGraphDegreeAttributes *degreeAttributes = [JVGraphDegreeAttributes attributes];
        NSUInteger node1Index;
        NSUInteger node2Index;

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

        if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node2]) {
            node2Index = indexSet.firstIndex;
            node1Index = NSNotFound;
        } else {
            node2Index = NSNotFound;
            node1Index = indexSet.firstIndex;
        }

        if(node2Index == NSNotFound) {
            // Add the list to the position node1Index in the array
            [connectionList addObject:[connectionAttributes copy]];
            adjacencyArray = [_nodeMatrixArray lastObject];
            adjacencyArray[node1Index] = connectionList;

            [_nodeArray addObject:node2];

            // set up for node1
            // Get the list at position (node1Index, node2Index)
            adjacencyArray = [_nodeMatrixArray objectAtIndex:node1Index];
            connectionList = [adjacencyArray lastObject];

            connectionAttributes.adjacentNode = node2;
            connectionAttributes.initialNode = NO;

            [connectionList addObject:connectionAttributes];

            degreeAttributes.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
            [self incrementDegreeAtNodeIndex:node1Index];
            if(directed) {
                degreeAttributes.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
                [self incrementIndegreeAtNodeIndex:node1Index];
            }

            [_degreeInfoArray addObject:degreeAttributes];
        } else {
            // Get the list at position (node2Index, node1Index)
            adjacencyArray = [_nodeMatrixArray objectAtIndex:node2Index];
            connectionList = [adjacencyArray lastObject];

            [connectionList addObject:[connectionAttributes copy]];

            // set up for node1
            connectionAttributes.adjacentNode = node2;
            connectionAttributes.initialNode = NO;

            connectionList = [JVMutableSinglyLinkedList list];

            [connectionList addObject:connectionAttributes];
            adjacencyArray = [_nodeMatrixArray lastObject];
            [adjacencyArray addObject:connectionList];

            [_nodeArray addObject:node1];

            [self incrementDegreeAtNodeIndex:node2Index];
            degreeAttributes.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
            if(directed) {
                [self incrementOutdegreeAtNodeIndex:node2Index];
                degreeAttributes.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
            }

            [_degreeInfoArray addObject:degreeAttributes];
        }

        ++_uniqueIncidenceCount;
    } else { // insert two unique nodes
	    // Order matters! The rule is to deal with the initial node
	    // first.
        JVGraphDegreeAttributes *degreeAttributes2 = [JVGraphDegreeAttributes attributes], *degreeAttributes1 = [JVGraphDegreeAttributes attributes];
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
    	[connectionList addObject:[connectionAttributes copy]];

    	[_nodeMatrixArray addObject:[NSMutableArray arrayWithArray:adjacencyArray]];

	    [_nodeArray addObject:node2];

	    // set up for node1
	    [connectionList removeFirstObject];

	    connectionAttributes.adjacentNode = node2;
        connectionAttributes.initialNode = NO;

	    // Add to the list at position (node1Index, node2Index)
	    connectionList = [adjacencyArray objectAtIndex:([adjacencyArray count] - 2)];
    	[connectionList addObject:connectionAttributes];

    	[_nodeMatrixArray addObject:[NSMutableArray arrayWithArray:adjacencyArray]];

	    [_nodeArray addObject:node1];

        degreeAttributes2.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
        degreeAttributes1.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
	    if(directed) {
	    	// node 2 contributes outdegree
            degreeAttributes2.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;

	    	// node 1 contributes indegree
            degreeAttributes1.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
	    }

	    ++_uniqueIncidenceCount;
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
    		for(JVGraphConnectionAttributes *connectionAttributes in list.objectEnumerator) {
    			if(connectionAttributes.isDirected) {
    				if(connectionAttributes.isInitialNode) {
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
        [_degreeInfoArray removeObjectAtIndex:indexSet.firstIndex];
    }
}

- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value {
    NSUInteger node1Index, node2Index;
	JVMutableSinglyLinkedList *connectionList;
    BOOL foundMatch;
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1] || [obj isEqual:node2]);
    }];

    if((indexSet.count == 1) && [node1 isEqual:node2]) { // remove self loop
    	connectionList = _nodeMatrixArray[indexSet.firstIndex][indexSet.firstIndex];

    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator.allObjects) {
    		if([self connectionAttributes:connectionAttributes matchesWithDirected:directed value:value]) {
    			[connectionList removeObject:connectionAttributes];
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

    	connectionList = _nodeMatrixArray[node2Index][node1Index];

    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator.allObjects) {
    		if([self connectionAttributes:connectionAttributes matchesWithDirected:directed value:value] && (foundMatch == NO)) {
    			foundMatch = YES;
    			[connectionList removeObject:connectionAttributes];
    			[self decrementDegreeAtNodeIndex:node2Index];
    			[self decrementDegreeAtNodeIndex:node1Index];
    			if(directed) {
	    			if(connectionAttributes.isInitialNode) {
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

	connectionList = _nodeMatrixArray[node1Index][node2Index];

	for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator.allObjects) {
		if([self connectionAttributes:connectionAttributes matchesWithDirected:directed value:value]) {
			[connectionList removeObject:connectionAttributes];
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

	    connectionList = _nodeMatrixArray[node1Index][node2Index];

    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator) {
    		if([self connectionAttributes:connectionAttributes matchesWithDirected:directed value:value]) {
    			if(directed) {
    				if(connectionAttributes.isDirected && connectionAttributes.isInitialNode) {
	    				return YES;
	    			}
    			} else {
    				if(connectionAttributes.isUndirected) {
	    				return YES;
	    			}
    			}
    		}
    	}
    }

    return NO;
}

- (NSUInteger)degreeOfNode:(id)node {
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	JVGraphDegreeAttributes *degreeAttributes = [_degreeInfoArray objectAtIndex:indexSet.firstIndex];
        return degreeAttributes.degree;
    }

    return 0;
}

- (NSUInteger)directedConnectionCount {
	return _directedConnectionCount;
}

- (NSUInteger)indegreeOfNode:(id)node {
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	JVGraphDegreeAttributes *degreeAttributes = [_degreeInfoArray objectAtIndex:indexSet.firstIndex];
        return degreeAttributes.indegree;
    }

    return 0;
}

- (NSUInteger)nodeCount {
	return [_nodeArray count];
}

- (NSUInteger)outdegreeOfNode:(id)node {
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    if(indexSet.firstIndex != NSNotFound) {
    	JVGraphDegreeAttributes *degreeAttributes = [_degreeInfoArray objectAtIndex:indexSet.firstIndex];
        return degreeAttributes.outdegree;
    }

    return 0;
}

- (NSUInteger)undirectedConnectionCount {
	return _undirectedConnectionCount;
}

- (NSUInteger)uniqueIncidenceCount {
    return _uniqueIncidenceCount;
}

#pragma mark - Private Methods

- (BOOL)connectionAttributes:(JVGraphConnectionAttributes *)attributes matchesWithDirected:(BOOL)directed value:(NSValue *)value {
	return ((attributes.isDirected && directed) || (!attributes.isDirected && !directed)) && [attributes.value isEqualToValue:value];
}


#pragma mark - Private Node Properties Accessor Methods

- (void)decrementDegreeAtNodeIndex:(NSUInteger)nodeIndex {
    [self updateDegreeAtNodeIndex:nodeIndex withAmount:-1];
}

- (void)decrementIndegreeAtNodeIndex:(NSUInteger)nodeIndex {
    [self updateIndegreeAtNodeIndex:nodeIndex withAmount:-1];
}

- (void)decrementOutdegreeAtNodeIndex:(NSUInteger)nodeIndex {
    [self updateOutdegreeAtNodeIndex:nodeIndex withAmount:-1];
}

- (void)incrementDegreeAtNodeIndex:(NSUInteger)nodeIndex {
    [self updateDegreeAtNodeIndex:nodeIndex withAmount:1];
}

- (void)incrementIndegreeAtNodeIndex:(NSUInteger)nodeIndex {
    [self updateIndegreeAtNodeIndex:nodeIndex withAmount:1];
}

- (void)incrementOutdegreeAtNodeIndex:(NSUInteger)nodeIndex {
    [self updateOutdegreeAtNodeIndex:nodeIndex withAmount:1];
}

- (void)updateDegreeAtNodeIndex:(NSUInteger)nodeIndex withAmount:(NSInteger)amount {
    JVGraphDegreeAttributes *degreeAttributes = _degreeInfoArray[nodeIndex];
    [degreeAttributes updateDegreeWithAmount:amount];
}

- (void)updateIndegreeAtNodeIndex:(NSUInteger)nodeIndex withAmount:(NSInteger)amount {
    JVGraphDegreeAttributes *degreeAttributes = _degreeInfoArray[nodeIndex];
    [degreeAttributes updateIndegreeWithAmount:amount];
}

- (void)updateOutdegreeAtNodeIndex:(NSUInteger)nodeIndex withAmount:(NSInteger)amount {
    JVGraphDegreeAttributes *degreeAttributes = _degreeInfoArray[nodeIndex];
    [degreeAttributes updateOutdegreeWithAmount:amount];
}

@end