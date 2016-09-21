#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"
#import "../JVMutableSinglyLinkedList.h"
#import "JVGraphConstants.h"
#import "JVGraphConnectionAttributes.h"
#import "JVGraphDegreeAttributes.h"

/****************************
** JVGraphAALAConnectionStore
** An adjacency list implementation.
** Array to store vertices; Array of adjacency Lists of connection
** properties Arrays.
** Efficient with graphs with a small amount of vertices and
** connections.
*/
@interface JVGraphAALAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>



@end

@implementation JVGraphAALAConnectionStore {
	NSMutableArray<JVMutableSinglyLinkedList<JVGraphConnectionAttributes *> *> *_adjacencyArray;
    NSMutableArray<JVGraphDegreeAttributes *> *_degreeInfoArray;
	NSUInteger _directedConnectionCount;
	NSMutableArray *_nodeArray;
	NSUInteger _undirectedConnectionCount;
    NSUInteger _uniqueIncidenceCount;
}

#pragma mark - Initializing a Graph AALA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_nodeArray = [NSMutableArray array];
		_adjacencyArray = [NSMutableArray array];
        _degreeInfoArray = [NSMutableArray array];
	}

	return self;
}

#pragma mark - Adding to a Graph AALA Connection Store

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
    JVGraphConnectionAttributes *connectionAttributes;
    JVMutableSinglyLinkedList *connectionList;

    if(directed) {
        ++_directedConnectionCount;
    } else {
        ++_undirectedConnectionCount;
    }

    connectionAttributes = [JVGraphConnectionAttributes attributesWithAdjacentNode:node1 directed:directed initialNode:YES value:value];

    NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1] || [obj isEqual:node2]);
    }];

    if(indexSet.count == 2) { // not a self loop and both are preexisting nodes
        NSUInteger node1Index;
        NSUInteger node2Index;
        BOOL isUniqueIncidence = YES;

        if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node2]) {
            node2Index = indexSet.firstIndex;
            node1Index = indexSet.lastIndex;
        } else {
            node2Index = indexSet.lastIndex;
            node1Index = indexSet.firstIndex;
        }

        connectionList = [_adjacencyArray objectAtIndex:node1Index];
        // Incidence is unique if one of the nodes is not involved in any of the
        // connections of the other.
        for(JVGraphConnectionAttributes *connAttributes in connectionList.objectEnumerator) {
            if([connAttributes.adjacentNode isEqual:node2]) {
                isUniqueIncidence = NO;
                break;
            }
        }

        if(isUniqueIncidence) ++_uniqueIncidenceCount;

        connectionList = [_adjacencyArray objectAtIndex:node2Index];
        [connectionList addObject:[connectionAttributes copy]];

        // node1 setup
        connectionList = [_adjacencyArray objectAtIndex:node1Index];

        connectionAttributes.adjacentNode = node2;
        connectionAttributes.initialNode = NO;

        [connectionList addObject:connectionAttributes];

        [self incrementDegreeAtNodeIndex:node2Index];
        [self incrementDegreeAtNodeIndex:node1Index];

        if(directed) {
            [self incrementOutdegreeAtNodeIndex:node2Index];
            [self incrementIndegreeAtNodeIndex:node1Index];
        }
    } else if([node1 isEqual:node2] && (indexSet.count == 1)) { // self loop with preexisting nodes
        BOOL isUniqueIncidence = YES;
        connectionList = [_adjacencyArray objectAtIndex:indexSet.firstIndex];

        // check for unique incidence
        for(JVGraphConnectionAttributes *connAttributes in connectionList.objectEnumerator) {
            if([connAttributes.adjacentNode isEqual:node2]) {
                isUniqueIncidence = NO;
                break;
            }
        }

        if(isUniqueIncidence) ++_uniqueIncidenceCount;

        [connectionList addObject:connectionAttributes];

        [self updateDegreeAtNodeIndex:indexSet.firstIndex withAmount:2];

        if(directed) {
            [self incrementOutdegreeAtNodeIndex:indexSet.firstIndex];
            [self incrementOutdegreeAtNodeIndex:indexSet.firstIndex];
         }
    } else if((indexSet.count == 0) && [node1 isEqual:node2]) { // new node, new self loop
        JVGraphDegreeAttributes *degreeAttributes = [JVGraphDegreeAttributes attributes];
    	[_nodeArray addObject:node2];

	    connectionList = [JVMutableSinglyLinkedList list];

	    [connectionList addObject:connectionAttributes];
	    [_adjacencyArray addObject:connectionList];

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

        if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node2]) {
            node2Index = indexSet.firstIndex;
            node1Index = NSNotFound;
        } else {
            node2Index = NSNotFound;
            node1Index = indexSet.firstIndex;
        }

        if(node2Index == NSNotFound) {
            [_nodeArray addObject:node2];

            connectionList = [JVMutableSinglyLinkedList list];

            [connectionList addObject:[connectionAttributes copy]];
            [_adjacencyArray addObject:connectionList];

            // set up for node1
            connectionList = [_adjacencyArray objectAtIndex:node1Index];

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
            connectionList = [_adjacencyArray objectAtIndex:node2Index];

            [connectionList addObject:[connectionAttributes copy]];

            // set up for node1
            [_nodeArray addObject:node1];

            connectionList = [JVMutableSinglyLinkedList list];

            connectionAttributes.adjacentNode = node2;
            connectionAttributes.initialNode = NO;

            [connectionList addObject:connectionAttributes];
            [_adjacencyArray addObject:connectionList];

            [self incrementDegreeAtNodeIndex:node2Index];
            degreeAttributes.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
            if(directed) {
                [self incrementOutdegreeAtNodeIndex:node2Index];
                degreeAttributes.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
            }

            [_degreeInfoArray addObject:degreeAttributes];
        }
        ++_uniqueIncidenceCount;
    } else if(indexSet.count == 0) { // insert two unique nodes
	    // Order matters! The rule is to deal with the initial node
	    // first.
        JVGraphDegreeAttributes *degreeAttributes2 = [JVGraphDegreeAttributes attributes], *degreeAttributes1 = [JVGraphDegreeAttributes attributes];

	    [_nodeArray addObject:node2];

	    connectionList = [JVMutableSinglyLinkedList list];

	    [connectionList addObject:[connectionAttributes copy]];
	    [_adjacencyArray addObject:[connectionList copy]];

	    // set up for node1
	    [connectionList removeFirstObject];

        [_nodeArray addObject:node1];

	    connectionAttributes.adjacentNode = node2;
        connectionAttributes.initialNode = NO;
	    [connectionList addObject:connectionAttributes];

	    [_adjacencyArray addObject:connectionList];

        degreeAttributes2.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
        degreeAttributes1.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
	    if(directed) {
            degreeAttributes2.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
            degreeAttributes1.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
	    }

        [_degreeInfoArray addObject:degreeAttributes2];
        [_degreeInfoArray addObject:degreeAttributes1];

	    ++_uniqueIncidenceCount;
    }
}

#pragma mark - Removing from a Graph AALA Connection Store

- (void)removeNode:(id)node {
    NSMutableArray *uniqueIncidenceArray;
    NSUInteger nodeIndex;
	// Get the index of the node, if it exists
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node]);
    }];

    nodeIndex = indexSet.firstIndex;
    if(nodeIndex== NSNotFound) return;

    uniqueIncidenceArray = [NSMutableArray array];

    // Find other nodes that are adjacent to this node and
    // delete all connections that involve this node.
    indexSet = [_adjacencyArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(JVMutableSinglyLinkedList *adjacentNodeList, NSUInteger idx, BOOL *stop) {
        NSUInteger degreeCount, outdegreeCount, indegreeCount;
        for(JVGraphConnectionAttributes *connectionAttributes in adjacentNodeList.objectEnumerator.allObjects) {
            if([connectionAttributes.adjacentNode isEqual:node]) {
                if(![uniqueIncidenceArray containsObject:[_nodeArray objectAtIndex:idx]]) [uniqueIncidenceArray addObject:[_nodeArray objectAtIndex:idx]];
                ++degreeCount;
                if(connectionAttributes.isDirected) {
                    if(connectionAttributes.isInitialNode) {
                        --outdegreeCount;
                    } else {
                        --indegreeCount;
                    }
                    --_directedConnectionCount;
                } else {
                    --_undirectedConnectionCount;
                }

                [adjacentNodeList removeObject:connectionAttributes];
            }
        }

        [self updateDegreeAtNodeIndex:idx withAmount:-degreeCount];
        [self updateIndegreeAtNodeIndex:idx withAmount:-indegreeCount];
        [self updateOutdegreeAtNodeIndex:idx withAmount:-outdegreeCount];

        return NO;
    }];

    [_nodeArray removeObjectAtIndex:nodeIndex];
    [_adjacencyArray removeObjectAtIndex:nodeIndex];
    [_degreeInfoArray removeObjectAtIndex:nodeIndex];
    _uniqueIncidenceCount -= [uniqueIncidenceArray count];
}

- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value {
    NSUInteger node1Index, node2Index;
	JVMutableSinglyLinkedList *connectionList;
	JVGraphConnectionOrientationOptions connectionOrientation;
	BOOL foundMatch;
	NSIndexSet *indexSet = [_nodeArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    	return ([obj isEqual:node1] || [obj isEqual:node2]);
    }];

    if(directed) {
    	connectionOrientation = JVGraphConnectionOrientationDirected;
    } else {
    	connectionOrientation = JVGraphConnectionOrientationUndirected;
    }

    if((indexSet.count == 1) && [node1 isEqual:node2]) { // remove self loop
    	NSUInteger uniqueCount;
    	connectionList = [_adjacencyArray objectAtIndex:indexSet.firstIndex];

    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator.allObjects) {
    		if([connectionAttributes.adjacentNode isEqual:node1]) {
    			if(((connectionAttributes.isDirected && directed) || (!connectionAttributes.isDirected && !directed)) && [connectionAttributes.value isEqualToValue:value] && (foundMatch == NO)) {
    				foundMatch = YES;
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
    			}

    			++uniqueCount;
    		}
    	}

    	// Being careful here. It is possible that we found a node matching
    	// the node to remove in name but not in the other parameters.
    	// The incidence count is incremented whenever we find a node matching
    	// the name given - connections to the same node, however, with
    	// different connection properties.
    	// If we did not find an exact match, then it doesn't matter what the
    	// incidence count is. If we found a match, then we must make sure it is
    	// the only adjacent node with that name in the list before we can
    	// reduce the _uniqueIncidenceCount;
    	if(foundMatch && (uniqueCount == 1)) --_uniqueIncidenceCount;

    	return;
    } else if(indexSet.count == 2) {
    	NSUInteger uniqueCount;

    	if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node2]) {
    		node2Index = indexSet.firstIndex;
    		node1Index = indexSet.lastIndex;
    	} else {
    		node2Index = indexSet.lastIndex;
    		node1Index = indexSet.firstIndex;
    	}

	    connectionList = [_adjacencyArray objectAtIndex:node2Index];
    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator.allObjects) {
    		if([connectionAttributes.adjacentNode isEqual:node1]) {
    			if(((connectionAttributes.isDirected && directed) || (!connectionAttributes.isDirected && !directed)) && [connectionAttributes.value isEqualToValue:value] && (foundMatch == NO)) {
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
    			}

    			++uniqueCount;
    		}
    	}

    	// Being careful here. It is possible that we found a node matching
    	// the node to remove in name but not in the other parameters.
    	// The incidence count is incremented whenever we find a node matching
    	// the name given - connections to the same node, however, with
    	// different connection properties.
    	// If we did not find an exact match, then it doesn't matter what the
    	// incidence count is. If we found a match, then we must make sure it is
    	// the only adjacent node with that name in the list before we can
    	// reduce the _uniqueIncidenceCount;
    	if(foundMatch && (uniqueCount == 1)) --_uniqueIncidenceCount;
    } else {
    	return;
    }

    if(foundMatch == NO) return;

    // set up for node1
    connectionList = [_adjacencyArray objectAtIndex:node1Index];
	for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator.allObjects) {
		if([connectionAttributes.adjacentNode isEqual:node2] && ((connectionAttributes.isDirected && directed) || (!connectionAttributes.isDirected && !directed)) && [connectionAttributes.value isEqualToValue:value]) {
			[connectionList removeObject:connectionAttributes];
			break;
		}
	}
}

#pragma mark - Querying a Graph AALA Connection Store

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
    	return ([obj isEqual:node1]);
    }];

    if((indexSet.count == 2) || ((indexSet.count == 1) && ([node1 isEqual:node2]))) {
    	if([[_nodeArray objectAtIndex:indexSet.firstIndex] isEqual:node1]) {
			node1Index = indexSet.firstIndex;
			node2Index = indexSet.lastIndex;
		} else {
			node1Index = indexSet.lastIndex;
			node2Index = indexSet.firstIndex;
		}

	    connectionList = [_adjacencyArray objectAtIndex:node1Index];
    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator) {
    		if([connectionAttributes.adjacentNode isEqual:node2] && [connectionAttributes.value isEqualToValue:value]) {
    			if(directed) {
    				if(connectionAttributes.isDirected && connectionAttributes.isInitialNode) return YES;
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