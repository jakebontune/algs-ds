#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"
#import "JVGraphConstants.h"
#import "../JVMutableSinglyLinkedList.h"
#import "JVGraphConnectionAttributes.h"
#import "JVGraphDegreeAttributes.h"
#import "../JVBlockEnumerator.h"

/****************************
** JVGraphDLAConnectionStore
** An adjacency list implementation.
** Dictionary of adjacency Lists of connection properties Arrays.
** Efficient with graphs with a great amount of vertices and a small
** amount of connections.
*/
@interface JVGraphDLAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>



@end

@implementation JVGraphDLAConnectionStore {
	NSUInteger _directedConnectionCount;
	NSMutableDictionary<id <NSCopying>, JVMutableSinglyLinkedList *> *_nodeDictionary;
	NSMutableDictionary<id <NSCopying>, JVGraphDegreeAttributes *> *_degreeInfoDictionary;
	NSUInteger _undirectedConnectionCount;
	NSUInteger _uniqueIncidenceCount;
}

#pragma mark - Initializing a Graph DLA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_nodeDictionary = [NSMutableDictionary dictionary];
		_degreeInfoDictionary = [NSMutableDictionary dictionary];
	}

	return self;
}

#pragma mark - Adding to a Graph DLA Connection Store

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
    JVMutableSinglyLinkedList<JVGraphConnectionAttributes *> *node2List = _nodeDictionary[node2], *node1List = _nodeDictionary[node1];
    JVGraphConnectionAttributes *connectionAttributes;

    if(directed) {
    	++_directedConnectionCount;
    } else {
    	++_undirectedConnectionCount;
    }

    connectionAttributes = [JVGraphConnectionAttributes attributesWithAdjacentNode:node1 directed:directed initialNode:YES value:value];

    if(![node1 isEqual:node2] && (node2List != nil) && (node1List != nil)) { // not a self loop and both are preexisting nodes

    	BOOL isUniqueIncidence = YES;

    	// check for unique incidence
		for(JVGraphConnectionAttributes *attributes in node2List.objectEnumerator) {
			if([attributes.adjacentNode isEqual:node1]) {
				isUniqueIncidence = NO;
				break;
			}
		}

		if(isUniqueIncidence) ++_uniqueIncidenceCount;

    	[node2List addObject:[connectionAttributes copy]];

		connectionAttributes.adjacentNode = node2;
		connectionAttributes.initialNode = NO;

		[node1List addObject:connectionAttributes];

		// update degrees
		[self incrementDegreeOfNode:node2];
		[self incrementDegreeOfNode:node1];

		if(directed) {
			[self incrementOutdegreeOfNode:node2];
			[self incrementIndegreeOfNode:node1];
		}
    } else if([node1 isEqual:node2] && (node2List != nil)) { // self loop with prexisting node
    	BOOL isUniqueIncidence = YES;

    	// check for unique incidence
		for(JVGraphConnectionAttributes *attributes in node2List.objectEnumerator) {
			if([attributes.adjacentNode isEqual:node2]) {
				isUniqueIncidence = NO;
				break;
			}
		}

		if(isUniqueIncidence) ++_uniqueIncidenceCount;

    	[node2List addObject:connectionAttributes];

		// update degrees
		[self updateDegreeOfNode:node2 withAmount:2]; // self loops contribute two degrees

		if(directed) {
			[self incrementOutdegreeOfNode:node2];
			[self incrementIndegreeOfNode:node2];
		}
    } else if((node2List == nil) && [node1 isEqual:node2]) { // new self loop with new node
    	JVGraphDegreeAttributes *degreeAttributes = [JVGraphDegreeAttributes attributes];
    	++_uniqueIncidenceCount;

    	node2List = [JVMutableSinglyLinkedList list];

		[node2List addObject:connectionAttributes];

    	_nodeDictionary[node2] = [node2List copy];

    	degreeAttributes.degree = kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE;
		if(directed) {
			degreeAttributes.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
			degreeAttributes.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
		}

    	_degreeInfoDictionary[node2] = degreeAttributes;
    } else if((node2List != nil) && (node1List == nil)) {
    	++_uniqueIncidenceCount;

    	[node2List addObject:[connectionAttributes copy]];

		// node1 setup
		node1List = [JVMutableSinglyLinkedList list];
		JVGraphDegreeAttributes *degreeAttributes = [JVGraphDegreeAttributes attributes];
		connectionAttributes.adjacentNode = node2;
		connectionAttributes.initialNode = NO;

		[node1List addObject:connectionAttributes];
		_nodeDictionary[node1] = [node1List copy];

		// update degrees
		[self incrementDegreeOfNode:node2];
		degreeAttributes.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;

		if(directed) {
			[self incrementOutdegreeOfNode:node2];
			degreeAttributes.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
		}

		_degreeInfoDictionary[node1] = degreeAttributes;
    } else if((node2List == nil) && (node1List != nil)) {
    	++_uniqueIncidenceCount;

    	JVGraphDegreeAttributes *degreeAttributes = [JVGraphDegreeAttributes attributes];
    	node2List = [JVMutableSinglyLinkedList list];

		[node2List addObject:[connectionAttributes copy]];

		_nodeDictionary[node2] = [node2List copy];

		// node1 setup
		connectionAttributes.adjacentNode = node2;
		connectionAttributes.initialNode = NO;

		[node1List addObject:connectionAttributes];


		// update degrees
		degreeAttributes.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
		[self incrementDegreeOfNode:node1];

		if(directed) {
			degreeAttributes.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;

			[self incrementIndegreeOfNode:node1];
		}

		_degreeInfoDictionary[node2] = degreeAttributes;
    } else { // both are new entries
    	++_uniqueIncidenceCount;

    	JVGraphDegreeAttributes *degreeAttributes1 = [JVGraphDegreeAttributes attributes];
    	JVGraphDegreeAttributes *degreeAttributes2 = [JVGraphDegreeAttributes attributes];
    	node2List = [JVMutableSinglyLinkedList list];

		[node2List addObject:[connectionAttributes copy]];

		_nodeDictionary[node2] = [node2List copy];

		// node1 setup
		node1List = [JVMutableSinglyLinkedList list];

		connectionAttributes.adjacentNode = node2;
		connectionAttributes.initialNode = NO;

		[node1List addObject:connectionAttributes];
		_nodeDictionary[node1] = [node1List copy];

		// update degrees
		degreeAttributes2.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
		degreeAttributes1.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;

		if(directed) {
			degreeAttributes2.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
			degreeAttributes1.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
		}

		_degreeInfoDictionary[node2] = degreeAttributes2;
		_degreeInfoDictionary[node1] = degreeAttributes1;
    }
}

#pragma mark - Removing from a Graph DLA Connection Store

- (void)removeNode:(id)node {
	JVMutableSinglyLinkedList *list = _nodeDictionary[node], *adjacentNodeList;
	NSMutableArray *uniqueIncidenceArray;

	if(list == nil) return;

	uniqueIncidenceArray = [NSMutableArray array];

	for(JVGraphConnectionAttributes *connectionAttributes in list.objectEnumerator) {
		NSUInteger degreeCount, outdegreeCount, indegreeCount;
		id adjacentNode = connectionAttributes.adjacentNode;
		if(![adjacentNode isEqual:node]) {
			adjacentNodeList = _nodeDictionary[adjacentNode];
			for(JVGraphConnectionAttributes *connAttributes in adjacentNodeList.objectEnumerator.allObjects) {
				if([connAttributes.adjacentNode isEqual:node]) {
					++degreeCount;
					if(connAttributes.isDirected) {
						if([connAttributes isInitialNode]) {
							++outdegreeCount;
						} else {
							++indegreeCount;
						}
						--_directedConnectionCount;
					} else {
						--_undirectedConnectionCount;
					}

					[adjacentNodeList removeObject:connAttributes];
				}
			}

			[self updateDegreeOfNode:adjacentNode withAmount:-degreeCount];
			[self updateIndegreeOfNode:adjacentNode withAmount:-indegreeCount];
			[self updateOutdegreeOfNode:adjacentNode withAmount:-outdegreeCount];
		} else {
			if(connectionAttributes.isDirected) {
				--_directedConnectionCount;
			} else {
				--_undirectedConnectionCount;
			}
		}

		if(![uniqueIncidenceArray containsObject:adjacentNode]) [uniqueIncidenceArray addObject:adjacentNode];
	}

	[_nodeDictionary removeObjectForKey:node];
	[_degreeInfoDictionary removeObjectForKey:node];
	_uniqueIncidenceCount -= [uniqueIncidenceArray count];
}

- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value {
    JVMutableSinglyLinkedList *adjacencyList = _nodeDictionary[node2], *adjacencyList1 = _nodeDictionary[node1];
    JVGraphConnectionOrientationOptions connectionOrientation;
    NSUInteger uniqueCount;
    BOOL foundMatch;

    if((adjacencyList == nil) || (adjacencyList1 == nil)) return;

    if(directed) {
    	connectionOrientation = JVGraphConnectionOrientationDirected;
    } else {
    	connectionOrientation = JVGraphConnectionOrientationUndirected;
    }

    if([node1 isEqual:node2]) {
    	for(JVGraphConnectionAttributes *connectionAttributes in adjacencyList.objectEnumerator.allObjects) {
	    	if([connectionAttributes.adjacentNode isEqual:node1]) {
	    		if(((connectionAttributes.isDirected && directed) || (!connectionAttributes.isDirected && !directed)) && [connectionAttributes.value isEqualToValue:value] && (foundMatch == NO)) {
	    			foundMatch = YES;
	    			[adjacencyList removeObject:connectionAttributes];
	    			[self updateDegreeOfNode:node2 withAmount:-2];

	    			if(directed) {
	    				[self decrementIndegreeOfNode:node2];
	    				[self decrementOutdegreeOfNode:node2];
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
    } else {
    	for(JVGraphConnectionAttributes *connectionAttributes in adjacencyList.objectEnumerator.allObjects) {
    		if([connectionAttributes.adjacentNode isEqual:node1]) {
    			if(((connectionAttributes.isDirected && directed) || (!connectionAttributes.isDirected && !directed)) && [connectionAttributes.value isEqualToValue:value] && (foundMatch == NO)) {
    				foundMatch = YES;
    				[adjacencyList removeObject:connectionAttributes];
    				[self decrementDegreeOfNode:node2];
	    			[self decrementDegreeOfNode:node1];
	    			if(directed) {
	    				if(connectionAttributes.isInitialNode) {
	    					[self decrementOutdegreeOfNode:node2];
	    					[self decrementIndegreeOfNode:node1];
	    				} else {
	    					[self decrementIndegreeOfNode:node2];
	    					[self decrementOutdegreeOfNode:node1];
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
    }

    if(foundMatch == NO) return;

    for(JVGraphConnectionAttributes *connectionAttributes in adjacencyList1.objectEnumerator.allObjects) {
		if([connectionAttributes.adjacentNode isEqual:node2] && ((connectionAttributes.isDirected && directed) || (!connectionAttributes.isDirected && !directed)) && [connectionAttributes.value isEqualToValue:value]) {
			[adjacencyList1 removeObject:connectionAttributes];
			break;
		}
	}
}

#pragma mark - Querying a Graph DLA Connection Store

- (NSUInteger)connectionCount {
    return (_directedConnectionCount + _undirectedConnectionCount);
}

- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2
                        directed:(BOOL)directed
                           value:(NSValue *)value {
    JVMutableSinglyLinkedList *adjacencyList = _nodeDictionary[node1];

    for(JVGraphConnectionAttributes *connectionAttributes in adjacencyList.objectEnumerator) {
    	if([connectionAttributes.adjacentNode isEqual:node2] && [connectionAttributes.value isEqualToValue:value]) {
    		if(directed) {
    			return connectionAttributes.isDirected && connectionAttributes.isInitialNode;
    		} else {
    			return connectionAttributes.isUndirected;
    		}
    	}
    }

    return NO;
}

- (NSUInteger)degreeOfNode:(id)node {
	JVGraphDegreeAttributes *degreeAttributes = _degreeInfoDictionary[node];
	if(degreeAttributes == nil) return 0;
	return degreeAttributes.degree;
}

- (NSUInteger)directedConnectionCount {
	return _directedConnectionCount;
}

- (NSUInteger)indegreeOfNode:(id)node {
	JVGraphDegreeAttributes *degreeAttributes = _degreeInfoDictionary[node];
	if(degreeAttributes == nil) return 0;
	return degreeAttributes.indegree;
}

- (NSUInteger)nodeCount {
	return [_nodeDictionary count];
}

- (NSUInteger)outdegreeOfNode:(id)node {
	JVGraphDegreeAttributes *degreeAttributes = _degreeInfoDictionary[node];
	if(degreeAttributes == nil) return 0;
	return degreeAttributes.outdegree;
}

- (NSUInteger)undirectedConnectionCount {
	return _undirectedConnectionCount;
}

- (NSUInteger)uniqueIncidenceCount {
	return _uniqueIncidenceCount;
}

#pragma mark - Enumerating a Graph DLA Connection Store

- (NSEnumerator *)adjacencyEnumerator {
	__block NSEnumerator *nodeEnumerator = _nodeDictionary.objectEnumerator;
	JVBlockEnumerator *enumerator = [[JVBlockEnumerator alloc] initWithBlock:^{
		id node = [nodeEnumerator nextObject];
		if(node != nil) {
			return [NSDictionary dictionaryWithObjectsAndKeys: _nodeDictionary[node].objectEnumerator.allObjects, node, nil];
		}

		return (NSDictionary *)nil;
	}];

	return enumerator;
}

- (NSEnumerator *)nodeEnumerator {
	return _nodeDictionary.keyEnumerator;
}

#pragma mark - Private Node Info Accessor Methods

- (void)decrementDegreeOfNode:(id)node {
	[self updateDegreeOfNode:node withAmount:-1];
}

- (void)decrementIndegreeOfNode:(id)node {
	[self updateIndegreeOfNode:node withAmount:-1];
}

- (void)decrementOutdegreeOfNode:(id)node {
	[self updateOutdegreeOfNode:node withAmount:-1];
}

- (void)incrementDegreeOfNode:(id)node {
	[self updateDegreeOfNode:node withAmount:1];
}

- (void)incrementIndegreeOfNode:(id)node {
	[self updateIndegreeOfNode:node withAmount:1];
}

- (void)incrementOutdegreeOfNode:(id)node {
	[self updateOutdegreeOfNode:node withAmount:1];
}

- (void)updateDegreeOfNode:(id)node withAmount:(NSInteger)amount {
	JVGraphDegreeAttributes *degreeAttributes = _degreeInfoDictionary[node];
	[degreeAttributes updateDegreeWithAmount:amount];
}

- (void)updateIndegreeOfNode:(id)node withAmount:(NSInteger)amount {
	JVGraphDegreeAttributes *degreeAttributes = _degreeInfoDictionary[node];
	[degreeAttributes updateIndegreeWithAmount:amount];
}

- (void)updateOutdegreeOfNode:(id)node withAmount:(NSInteger)amount {
	JVGraphDegreeAttributes *degreeAttributes = _degreeInfoDictionary[node];
	[degreeAttributes updateOutdegreeWithAmount:amount];
}

@end