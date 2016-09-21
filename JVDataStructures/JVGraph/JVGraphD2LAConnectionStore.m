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
** JVGraphD2LAConnectionStore
** Dictionary of adjacency Dictionaries of connections Lists of
** connection properties Arrays.
** An adjacency matrix implementation.
** Efficient with graphs with a great amount of vertices and
** connections.
*/
@interface JVGraphD2LAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>

@end

@implementation JVGraphD2LAConnectionStore {
	NSUInteger _directedConnectionCount;
	NSMutableDictionary<id <NSCopying>, JVMutableSinglyLinkedList *> *_nodeMatrixDictionary;
	NSMutableDictionary<id <NSCopying>, JVGraphDegreeAttributes *> *_degreeInfoDictionary;
	NSUInteger _undirectedConnectionCount;
	NSUInteger _uniqueIncidenceCount;
}

#pragma mark - Initializing a Graph D2LA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_nodeMatrixDictionary = [NSMutableDictionary dictionary];
		_degreeInfoDictionary = [NSMutableDictionary dictionary];
	}

	return self;
}

#pragma mark - Adding to a Graph D2LA Connection Store

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
    NSMutableDictionary *adjacencyDictionary2 = _nodeMatrixDictionary[node2], *adjacencyDictionary1 = _nodeMatrixDictionary[node1];
    JVMutableSinglyLinkedList *connectionList2 = adjacencyDictionary2[node1], *connectionList1 = adjacencyDictionary1[node2];
    JVGraphConnectionAttributes *connectionAttributes;

    if(directed) {
    	++_directedConnectionCount;
    } else {
    	++_undirectedConnectionCount;
    }

	connectionAttributes = [JVGraphConnectionAttributes attributesWithAdjacentNode:node1 directed:directed initialNode:YES value:value];

	if(![node1 isEqual:node2] && (adjacencyDictionary2 != nil) && (adjacencyDictionary1 != nil)) { // not a self loop and both are preexisting nodes
		if(connectionList2.count == 0) ++_uniqueIncidenceCount;

		[connectionList2 addObject:[connectionAttributes copy]];

		// node1 setup
		connectionAttributes.adjacentNode = node2;
		connectionAttributes.initialNode = NO;

		[connectionList1 addObject:connectionAttributes];

		[self incrementDegreeOfNode:node2];
		[self incrementDegreeOfNode:node1];

		if(directed) {
			[self incrementOutdegreeOfNode:node2];
			[self incrementIndegreeOfNode:node1];
		}
	} else if([node1 isEqual:node2] && (adjacencyDictionary2 != nil)) { // self loop with preexisting node
		if(connectionList2.count == 0) ++_uniqueIncidenceCount;

		[connectionList2 addObject:connectionAttributes];

		[self updateDegreeOfNode:node2 withAmount:kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE]; // self loops contribute two degrees

		if(directed) {
			[self incrementOutdegreeOfNode:node2];
			[self incrementIndegreeOfNode:node2];
		}
	} else if((adjacencyDictionary2 == nil) && [node1 isEqual:node2]) { // self loop with new node
		JVGraphDegreeAttributes *degreeAttributes = [JVGraphDegreeAttributes attributes];
		adjacencyDictionary2 = [NSMutableDictionary dictionary];

		++_uniqueIncidenceCount;

		connectionList2 = [JVMutableSinglyLinkedList list];

		// Inform all other vertices that they have a potential neighbor
		// Set all the vertices as potential neighbors to the new node
		for(id keyNode in _nodeMatrixDictionary) {
			_nodeMatrixDictionary[keyNode][node2] = [JVMutableSinglyLinkedList list];
			adjacencyDictionary[keyNode] = [JVMutableSinglyLinkedList list];
		}
		// once for the new node
		[connectionList2 addObject:connectionAttributes];
		adjacencyDictionary2[node2] = connectionList2;

		_nodeMatrixDictionary[node2] = adjacencyDictionary2;

		degreeAttributes.degree = kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE; // self loops contribute two degrees
		if(directed) {
			degreeAttributes.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
			degreeAttributes.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
		}

		_degreeInfoDictionary[node2] = degreeAttributes;
	} else if(((adjacencyDictionary2 != nil) && (adjacencyDictionary1 == nil)) || ((adjacencyDictionary1 != nil) && (adjacencyDictionary2 == nil))) {
		JVGraphDegreeAttributes *degreeAttributes = [JVGraphDegreeAttributes attributes];

		if(connectionList2 == nil) {
			adjacencyDictionary2 = [NSMutableDictionary dictionary];

			// Inform all other vertices that they have a potential neighbor
			// Set all the vertices as potential neighbors to the new node
			for(id keyNode in _nodeMatrixDictionary) {
				_nodeMatrixDictionary[keyNode][node2] = [JVMutableSinglyLinkedList list];
				adjacencyDictionary2[keyNode] = [JVMutableSinglyLinkedList list];
			}
			// one more for itself
			[connectionList2 addObject:[connectionAttributes copy]];
			adjacencyDictionary2[node1] = connectionList2;
			_nodeMatrixDictionary[node2] = adjacencyDictionary2;

			// node1 setup
			connectionAttributes.adjacentNode = node2;
			connectionAttributes.initialNode = NO;

			// Get the list at position (node1, node2);
			connectionList1 = _nodeMatrixDictionary[node1][node2];

			[connectionList1 addObject:connectionAttributes];

			degreeAttributes.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
			[self incrementDegreeOfNode:node1];
			if(directed) {
				degreeAttributes.outdegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
				[self incrementIndegreeOfNode:node1];
			}

			_degreeInfoDictionary[node2] = degreeAttributes;
		} else {
			// node1 setup
			adjacencyDictionary1 = [NSMutableDictionary dictionary];

			// Inform all other vertices that they have a potential neighbor
			// Set all the vertices as potential neighbors to the new node
			for(id keyNode in _nodeMatrixDictionary) {
				_nodeMatrixDictionary[keyNode][node1] = [JVMutableSinglyLinkedList list];
				adjacencyDictionary1[keyNode] = [JVMutableSinglyLinkedList list];
			}

			connectionAttributes.adjacentNode = node2;
			connectionAttributes.initialNode = NO;

			[connectionList1 addObject:[connectionAttributes copy]];
			adjacencyDictionary1[node2] = connectionList1;
			_nodeMatrixDictionary[node1] = adjacencyDictionary1;

			// node2 setup
			connectionAttributes.adjacentNode = node1;
			connectionAttributes.initialNode = YES;

			//Get the list at position (node2, node1);
			connectionList2 = _nodeMatrixDictionary[node2][node1];

			[connectionList2 addObject:connectionAttributes];

			[self incrementDegreeOfNode:node2];
			degreeAttributes.degree = kJV_GRAPH_DEFAULT_VALUE_ONE;
			if(directed) {
				[self incrementOutdegreeOfNode:node2];
				degreeAttributes.indegree = kJV_GRAPH_DEFAULT_VALUE_ONE;
			}

			_degreeInfoDictionary[node1] = degreeAttributes;
		}

		++_uniqueIncidenceCount;
	} else { // new unique entries
		JVGraphDegreeAttributes *degreeAttributes2 = [JVGraphDegreeAttributes attributes], *degreeAttributes1 = [JVGraphDegreeAttributes attributes];

		++_uniqueIncidenceCount;

		adjacencyDictionary2 = [NSMutableDictionary dictionary];
		adjacencyDictionary1 = [NSMutableDictionary dictionary];
		connectionList2 = [JVMutableSinglyLinkedList list];
		connectionList1 = [JVMutableSinglyLinkedList list];

		for(id keyNode in _nodeMatrixDictionary) {
			_nodeMatrixDictionary[keyNode][node2] = [JVMutableSinglyLinkedList list];
			_nodeMatrixDictionary[keyNode][node1] = [JVMutableSinglyLinkedList list];
			adjacencyDictionary2[keyNode] = [JVMutableSinglyLinkedList list];
			adjacencyDictionary1[keyNode] = [JVMutableSinglyLinkedList list];
		}

		[connectionList2 addObject:[connectionAttributes copy]];
		adjacencyDictionary2[node1] = connectionList2;
		_nodeMatrixDictionary[node2] = adjacencyDictionary2;

		// node1 setup
		connectionAttributes.adjacentNode = node2;
		connectionAttributes.initialNode = NO;

		[connectionList1 addObject:connectionAttributes];
		adjacencyDictionary1[node2] = connectionAttributes;
		_nodeMatrixDictionary[node1] = connectionList1;

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

#pragma mark - Removing from a Graph D2LA Connection Store

- (void)removeNode:(id)node {
	NSMutableDictionary *adjacencyDictionary = _nodeMatrixDictionary[node];

	if(adjacencyDictionary == nil) return;

	JVMutableSinglyLinkedList *connectionList;

	for(id keyNode in _nodeMatrixDictionary) {
		connectionList = _nodeMatrixDictionary[keyNode][node];
		NSUInteger indegreeCount, outdegreeCount;

		// If there was ever a connection in that grid location, we are
		// removing a unique incidence as we know all connections in the list
		// have to do soley with the two nodes involved.
		if(connectionList.count != 0) --_uniqueIncidenceCount;

		for(JVGraphConnectionAttributes *connectionAttributes in connectionList.objectEnumerator) {
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

		[self updateDegreeOfNode:keyNode withAmount:-connectionList.count];
		[self updateIndegreeOfNode:keyNode withAmount:-indegreeCount];
		[self updateOutdegreeOfNode:keyNode withAmount:-outdegreeCount];

		[_nodeMatrixDictionary[keyNode] removeObjectForKey:node];
	}

	[_nodeMatrixDictionary removeObjectForKey:node];
	[_degreeInfoDictionary removeObjectForKey:node];
}

- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value {
    NSMutableDictionary *adjacencyDictionary2 = _nodeMatrixDictionary[node2], *adjacencyDictionary1 = _nodeMatrixDictionary[node1];
    JVMutableSinglyLinkedList *connectionList2 = adjacencyDictionary2[node1], *connectionList1 = adjacencyDictionary1[node2];
    BOOL foundMatch;

    if((adjacencyDictionary2 != nil) && [node1 isEqual:node2]) { // remove self loop
    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList2.objectEnumerator.allObjects) {
    		if([self connectionAttributes:connectionAttributes matchesWithDirected:directed value:value]) {
    			[connectionList2 removeObject:connectionAttributes];
    			// self loops contribute two degrees
    			[self updateDegreeOfNode:node2 withAmount:-kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE];
    			if(directed) {
    				[self decrementIndegreeOfNode:node2];
    				[self decrementOutdegreeOfNode:node2];
    				==_directedConnectionCount;
    			} else {
    				--_undirectedConnectionCount;
    			}

    			if(connectionList2.count == 0) --_uniqueIncidenceCount;
    			break;
    		}
    	}

    	return;
    } else if((adjacencyDictionary2 != nil) && (adjacencyDictionary1 != nil)) {
    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList2.objectEnumerator.allObjects) {
    		if([self connectionAttributes:connectionAttributes matchesWithDirected:directed value:value] && (foundMatch == NO)) {
    			foundMatch = YES;
    			[connectionList2 removeObject:connectionAttributes];
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

    			if(connectionList2.count == 0) --_uniqueIncidenceCount;
    		}
    	}
    } else {
    	return;
    }

    if(foundMatch == NO) return;

    for(JVGraphConnectionAttributes *connectionAttributes in connectionList1.objectEnumerator.allObjects) {
    	if([self connectionAttributes:connectionAttributes matchesWithDirected:directed value:value]) {
    		[connectionList1 removeObject:connectionAttributes];
    		break;
    	}
    }
}

#pragma mark - Querying a Graph D2LA Connection Store

- (NSUInteger)connectionCount {
    return (_directedConnectionCount + _undirectedConnectionCount);
}

- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2
                        directed:(BOOL)directed
                           value:(NSValue *)value {
    NSMutableDictionary *adjacencyDictionary2 = _nodeMatrixDictionary[node2], *adjacencyDictionary1 = _nodeMatrixDictionary[node1];
    JVMutableSinglyLinkedList *connectionList2 = adjacencyDictionary2[node1];

    if((adjacencyDictionary2 != nil) && (adjacencyDictionary1 != nil)) {
    	for(JVGraphConnectionAttributes *connectionAttributes in connectionList2.objectEnumerator) {
    		if([self connectionAttributes:connectionAttributes matchesWithDirected:directed value:value]) {
    			if(directed) {
    				return connectionAttributes.isDirected && connectionAttributes.isInitialNode;
    			} else {
    				return connectionAttributes.isUndirected;
    			}
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

#pragma mark - Private Methods

- (BOOL)connectionAttributes:(JVGraphConnectionAttributes *)attributes matchesWithDirected:(BOOL)directed value:(NSValue *)value {
	return ((attributes.isDirected && directed) || (!attributes.isDirected && !directed)) && [attributes.value isEqualToValue:value];
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