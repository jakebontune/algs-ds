#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

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
	NSMutableArray *_degreeArray;
	NSUInteger _directedConnectionCount;
	NSUInteger _uniqueIncidenceCount;
	NSMutableArray *_indegreeArray;
	NSMutableArray *_nodeArray;
	NSMutableArray *_outdegreeArray;
	NSUInteger _undirectedConnectionCount;
}

#pragma mark - Initializing a Graph AALA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_nodeArray = [NSMutableArray array];
		_adjacencyArray = [NSMutableArray array];
		_degreeArray = [NSMutableArray array];
		_indegreeArray = [NSMutableArray array];
		_outdegreeArray = [NSMutableArray array];
	}

	return self;
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

#pragma mark - Adding to a Graph AALA Connection Store

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
    JVMutableSinglyLinkedList *connectionList;
	NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:kAALA_NUM_CONNECTION_PROPERTIES];
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

    propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node1;
    propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);
    propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] = @(connectionOrientation);
    propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] = value;

    if((indexSet.count == 0) && [node1 isEqual:node2]) { // new self loop
    	[_nodeArray addObject:node2];
	    [_degreeArray addObject:@(kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE)]; // self loops contribute two degrees

	    connectionList = [JVMutableSinglyLinkedList list];

	    [connectionList addObject:[NSArray arrayWithArray:propertyArray]];
	    [_adjacencyArray addObject:[connectionList copy]];

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
	    [_nodeArray addObject:node2];
	    [_degreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

	    [_nodeArray addObject:node1];
	    [_degreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

	    connectionList = [JVMutableSinglyLinkedList list];

	    [connectionList addObject:[NSArray arrayWithArray:propertyArray]];
	    [_adjacencyArray addObject:[connectionList copy]];

	    // set up for node1
	    [connectionList removeFirstObject];

	    nodeOrientation = JVGraphNodeOrientationTerminal;
	    propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
	    propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);

	    [connectionList addObject:[NSArray arrayWithArray:propertyArray]];

	    [_adjacencyArray addObject:connectionList];

	    if(directed) {
	    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
	    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

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
    		[_degreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

    		connectionList = [JVMutableSinglyLinkedList list];

    		[connectionList addObject:[NSArray arrayWithArray:propertyArray]];
    		[_adjacencyArray addObject:connectionList];

    		// set up for node1
    		[self incrementDegreeAtNodeIndex:node1Index];
    		connectionList = [_adjacencyArray objectAtIndex:node1Index];

    		nodeOrientation = JVGraphNodeOrientationTerminal;
    		propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
    		propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);

		    [connectionList addObject:[NSArray arrayWithArray:propertyArray]];

		    if(directed) {
		    	[_indegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ZERO)];
		    	[_outdegreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

		    	[self incrementIndegreeAtNodeIndex:node1Index];
		    }
    	} else {
    		[self incrementDegreeAtNodeIndex:node2Index];
    		connectionList = [_adjacencyArray objectAtIndex:node2Index];

		    [connectionList addObject:[NSArray arrayWithArray:propertyArray]];

		    // set up for node1
    		[_nodeArray addObject:node1];
    		[_degreeArray addObject:@(kJV_GRAPH_DEFAULT_VALUE_ONE)];

    		connectionList = [JVMutableSinglyLinkedList list];

    		nodeOrientation = JVGraphNodeOrientationTerminal;
    		propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
    		propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);

    		[connectionList addObject:[NSArray arrayWithArray:propertyArray]];
    		[_adjacencyArray addObject:connectionList];

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
    	BOOL isDistinctIncidence = YES;

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
	    for(NSArray *propsArray in connectionList.objectEnumerator.allObjects) {
	    	if([propsArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node2]) {
	    		isDistinctIncidence = NO;
	    		break;
	    	}
	    }

	    if(isDistinctIncidence) ++_uniqueIncidenceCount;

    	connectionList = [_adjacencyArray objectAtIndex:node2Index];
    	[connectionList addObject:[NSArray arrayWithArray:propertyArray]];

    	connectionList = [_adjacencyArray objectAtIndex:node1Index];

    	nodeOrientation = JVGraphNodeOrientationTerminal;
        propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
        propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(nodeOrientation);
        propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] = @(connectionOrientation);
        propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] = value;

	    [connectionList addObject:[NSArray arrayWithArray:propertyArray]];

	    [self incrementDegreeAtNodeIndex:node2Index];
	    [self incrementDegreeAtNodeIndex:node1Index];

	    if(directed) {
			[self incrementOutdegreeAtNodeIndex:node2Index];
			[self incrementIndegreeAtNodeIndex:node1Index];
	    }
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
        for(NSArray *propertyArray in adjacentNodeList.objectEnumerator.allObjects) {
            if([propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node]) {
                if(![uniqueIncidenceArray containsObject:[_nodeArray objectAtIndex:idx]]) [uniqueIncidenceArray addObject:[_nodeArray objectAtIndex:idx]];
                ++degreeCount;
                if([propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(JVGraphConnectionOrientationDirected)]) {
                    if([propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) {
                        --outdegreeCount;
                    } else {
                        --indegreeCount;
                    }
                    --_directedConnectionCount;
                } else {
                    --_undirectedConnectionCount;
                }

                [adjacentNodeList removeObject:propertyArray];
            }
        }

        [self updateDegreeAtNodeIndex:idx withAmount:-degreeCount];
        [self updateIndegreeAtNodeIndex:idx withAmount:-indegreeCount];
        [self updateOutdegreeAtNodeIndex:idx withAmount:-outdegreeCount];

        return NO;
    }];

    [_nodeArray removeObjectAtIndex:nodeIndex];
    [_adjacencyArray removeObjectAtIndex:nodeIndex];
    [_degreeArray removeObjectAtIndex:nodeIndex];
    [_indegreeArray removeObjectAtIndex:nodeIndex];
    [_outdegreeArray removeObjectAtIndex:nodeIndex];
    _uniqueIncidenceCount -= [uniqueIncidenceArray count];
}

- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value {
    NSUInteger node1Index, node2Index;
    NSArray *allAdjacentNodes;
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
    	allAdjacentNodes = connectionList.objectEnumerator.allObjects;

    	for(NSArray *propertyArray in allAdjacentNodes) {
    		if([propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqual:node1]) {
    			if([propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqual:@(connectionOrientation)] && [propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value] && (foundMatch == NO)) {
    				foundMatch = YES;
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
    	allAdjacentNodes = connectionList.objectEnumerator.allObjects;
    	for(NSArray *propertyArray in allAdjacentNodes) {
    		if([propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node1]) {
    			if([propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(connectionOrientation)] && [propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value] && (foundMatch == NO)) {
    				foundMatch = YES;
    				[connectionList removeObject:propertyArray];
    				[self decrementDegreeAtNodeIndex:node2Index];
	    			[self decrementDegreeAtNodeIndex:node1Index];
	    			if(directed) {
	    				if([propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) {
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
	allAdjacentNodes = connectionList.objectEnumerator.allObjects;
	for(NSArray *propertyArray in allAdjacentNodes) {
		if([propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node2] && [propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(connectionOrientation)] && [propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value]) {
			[connectionList removeObject:propertyArray];
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
    NSArray *allAdjacentNodes;
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
    	allAdjacentNodes = connectionList.objectEnumerator.allObjects;
    	for(NSArray *propertyArray in allAdjacentNodes) {
    		if([propertyArray[kAALA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node2] && [propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value]) {
    			if(directed) {
    				if([propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(JVGraphConnectionOrientationDirected)] && [propertyArray[kAALA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) return YES;
    			} else {
    				if([propertyArray[kAALA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(JVGraphConnectionOrientationUndirected)]) {
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

- (NSUInteger)uniqueIncidenceCount {
    return _uniqueIncidenceCount;
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