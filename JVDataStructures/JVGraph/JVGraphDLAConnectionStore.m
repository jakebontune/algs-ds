#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"
#import "JVGraphConstants.h"
#import "../JVMutableSinglyLinkedList.h"

// node info array keys
static NSUInteger const kDLA_NODE_INFO_ARRAY_CAPACITY = 3;
static NSUInteger const kDLA_NODE_KEY_DEGREE = 0;
static NSUInteger const kDLA_NODE_KEY_INDEGREE = 1;
static NSUInteger const kDLA_NODE_KEY_OUTDEGREE = 2;

// connection properties keys
static int const kDLA_CONNECTION_PROPERTIES_ARRAY_CAPACITY = 4;
static int const kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE = 0;
static int const kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION = 1;
static int const kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION = 2;
static int const kDLA_CONNECTION_PROPERTIES_CONNECTION_VALUE = 3;

/****************************
** JVGraphDLAConnectionStore
** An adjacency list implementation.
** Dictionary of adjacency Lists of connection properties Arrays.
** Useful for graphs with a great amount of vertices and a small
** amount of connections.
*/
@interface JVGraphDLAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>



@end

@implementation JVGraphDLAConnectionStore {
	NSUInteger _directedConnectionCount;
	NSUInteger _uniqueIncidenceCount;
	NSMutableDictionary *_nodeDictionary;
	NSMutableDictionary *_nodeInfoDictionary;
	NSUInteger _undirectedConnectionCount;
}

#pragma mark - Initializing a Graph DLA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_nodeDictionary = [NSMutableDictionary dictionary];
		_nodeInfoDictionary = [NSMutableDictionary dictionary];
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

#pragma mark - Adding to a Graph DLA Connection Store

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
    JVMutableSinglyLinkedList *node2List = _nodeDictionary[node2], *node1List = _nodeDictionary[node1];
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:kDLA_CONNECTION_PROPERTIES_ARRAY_CAPACITY];
    JVGraphConnectionOrientationOptions connectionOrientation;

    if(directed) {
    	connectionOrientation = JVGraphConnectionOrientationDirected;
    	++_directedConnectionCount;
    } else {
    	connectionOrientation = JVGraphConnectionOrientationUndirected;
    	++_undirectedConnectionCount;
    }

    propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node1;
    propertyArray[kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(JVGraphNodeOrientationInitial);
    propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] = @(connectionOrientation);
    propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_VALUE] = value;

    if(![node1 isEqual:node2] && (node2List != nil) && (node1List != nil)) {
    	// not a self loop and both are not new entries

    	BOOL isUniqueIncidence = YES;

    	[node2List addObject:[NSArray arrayWithArray:propertyArray]];

		// node1 setup
		propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
		propertyArray[kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(JVGraphNodeOrientationTerminal);

		[node1List addObject:[NSArray arrayWithArray:propertyArray]];

		// update degrees
		[self incrementDegreeOfNode:node2];
		[self incrementDegreeOfNode:node1];

		if(directed) {
			[self incrementOutdegreeOfNode:node2];
			[self incrementIndegreeOfNode:node1];
		}

		// check for uniqueion
		for(NSArray *propsArray in node2List.objectEnumerator) {
			if([propsArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node1]) {
				isUniqueIncidence = NO;
				break;
			}
		}

		if(isUniqueIncidence) ++_uniqueIncidenceCount;
    } else if([node1 isEqual:node2]) { // self loop with prexisting entries
    	BOOL isUniqueIncidence = YES;

    	[node2List addObject:[NSArray arrayWithArray:propertyArray]];

		// update degrees
		[self updateDegreeOfNode:node2 withAmount:2]; // self loops contribute two degrees

		if(directed) {
			[self incrementOutdegreeOfNode:node2];
			[self incrementIndegreeOfNode:node2];
		}

		// check for uniqueion
		for(NSArray *propsArray in node2List.objectEnumerator) {
			if([propsArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node2]) {
				isUniqueIncidence = NO;
				break;
			}
		}

		if(isUniqueIncidence) ++_uniqueIncidenceCount;
    } else if((node2List == nil) && [node1 isEqual:node2]) { // first self loop
    	++_uniqueIncidenceCount;
    	__strong NSNumber *nodeInfoArray[kDLA_CONNECTION_PROPERTIES_ARRAY_CAPACITY];
    	node2List = [JVMutableSinglyLinkedList list];

		[node2List addObject:[NSArray arrayWithArray:propertyArray]];

    	_nodeDictionary[node2] = [node2List copy];

    	nodeInfoArray[kDLA_NODE_KEY_DEGREE] = @(kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE);
		if(directed) {
			nodeInfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);
			nodeInfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);
		} else {
			nodeInfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
			nodeInfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
		}

    	_nodeInfoDictionary[node2] = *nodeInfoArray;
    } else if((node2List != nil) && (node1List == nil)) {
    	++_uniqueIncidenceCount;

    	[node2List addObject:[NSArray arrayWithArray:propertyArray]];

		// node1 setup
		node1List = [JVMutableSinglyLinkedList list];
		__strong NSNumber *nodeInfoArray[kDLA_CONNECTION_PROPERTIES_ARRAY_CAPACITY];

		propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node1;
		propertyArray[kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(JVGraphNodeOrientationTerminal);

		[node1List addObject:[NSArray arrayWithArray:propertyArray]];
		_nodeDictionary[node1] = [node1List copy];

		// update degrees
		[self incrementDegreeOfNode:node2];
		nodeInfoArray[kDLA_NODE_KEY_DEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);

		if(directed) {
			[self incrementOutdegreeOfNode:node2];

			nodeInfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);
			nodeInfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
		} else {
			nodeInfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
			nodeInfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
		}

		_nodeInfoDictionary[node1] = *nodeInfoArray;
    } else if((node2List == nil) && (node1List != nil)) {
    	++_uniqueIncidenceCount;
    	__strong NSNumber *nodeInfoArray[kDLA_CONNECTION_PROPERTIES_ARRAY_CAPACITY];
    	node2List = [JVMutableSinglyLinkedList list];

		[node2List addObject:[NSArray arrayWithArray:propertyArray]];

		_nodeDictionary[node2] = [node2List copy];

		// node1 setup
		propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node2;
		propertyArray[kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(JVGraphNodeOrientationTerminal);

		[node1List addObject:[NSArray arrayWithArray:propertyArray]];


		// update degrees
		nodeInfoArray[kDLA_NODE_KEY_DEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);
		[self incrementDegreeOfNode:node1];

		if(directed) {
			nodeInfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
			nodeInfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);

			[self incrementIndegreeOfNode:node1];
		} else {
			nodeInfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
			nodeInfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
		}

		_nodeInfoDictionary[node2] = *nodeInfoArray;
    } else { // both are new entries
    	++_uniqueIncidenceCount;

    	__strong NSNumber *node2InfoArray[kDLA_CONNECTION_PROPERTIES_ARRAY_CAPACITY];
    	__strong NSNumber *node1InfoArray[kDLA_CONNECTION_PROPERTIES_ARRAY_CAPACITY];
    	node2List = [JVMutableSinglyLinkedList list];

		[node2List addObject:[NSArray arrayWithArray:propertyArray]];

		_nodeDictionary[node2] = [node2List copy];

		// node1 setup
		node1List = [JVMutableSinglyLinkedList list];

		propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] = node1;
		propertyArray[kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION] = @(JVGraphNodeOrientationTerminal);

		[node1List addObject:[NSArray arrayWithArray:propertyArray]];
		_nodeDictionary[node1] = [node1List copy];

		// update degrees
		node2InfoArray[kDLA_NODE_KEY_DEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);
		node1InfoArray[kDLA_NODE_KEY_DEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);

		if(directed) {
			node2InfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
			node2InfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);

			node1InfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ONE);
			node1InfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
		} else {
			node2InfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
			node2InfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);

			node1InfoArray[kDLA_NODE_KEY_INDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
			node1InfoArray[kDLA_NODE_KEY_OUTDEGREE] = @(kJV_GRAPH_DEFAULT_VALUE_ZERO);
		}

		_nodeInfoDictionary[node2] = *node2InfoArray;
		_nodeInfoDictionary[node1] = *node1InfoArray;
    }
}

#pragma mark - Removing from a Graph DLA Connection Store

- (void)removeNode:(id)node {
	JVMutableSinglyLinkedList *list = _nodeDictionary[node], *adjacentNodeList;
	NSMutableArray *uniqueIncidenceArray;

	if(list == nil) return;

	uniqueIncidenceArray = [NSMutableArray array];

	for(NSArray *propertyArray in list.objectEnumerator.allObjects) {
		NSUInteger degreeCount, outdegreeCount, indegreeCount;
		id adjacentNode = propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE];
		if(![adjacentNode isEqual:node]) {
			adjacentNodeList = _nodeDictionary[adjacentNode];
			for(NSArray *propsArray in adjacentNodeList.objectEnumerator.allObjects) {
				if([propsArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node]) {
					++degreeCount;
					if([propsArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION]isEqualToNumber:@(JVGraphConnectionOrientationDirected)]) {
						if([propsArray[kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION]isEqualToNumber:@(JVGraphNodeOrientationInitial)]) {
							++outdegreeCount;
						} else {
							++indegreeCount;
						}
						--_directedConnectionCount;
					} else {
						--_undirectedConnectionCount;
					}

					[adjacentNodeList removeObject:propsArray];
				}
			}

			[self updateDegreeOfNode:adjacentNode withAmount:-degreeCount];
			[self updateIndegreeOfNode:adjacentNode withAmount:-indegreeCount];
			[self updateOutdegreeOfNode:adjacentNode withAmount:-outdegreeCount];
		} else {
			if([propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(JVGraphConnectionOrientationDirected)]) {
				--_directedConnectionCount;
			} else {
				--_undirectedConnectionCount;
			}
		}

		if(![uniqueIncidenceArray containsObject:adjacentNode]) [uniqueIncidenceArray addObject:adjacentNode];
	}

	[_nodeDictionary removeObjectForKey:node];
	[_nodeInfoDictionary removeObjectForKey:node];
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
    	for(NSArray *propertyArray in adjacencyList.objectEnumerator.allObjects) {
	    	if([propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node1]) {
	    		if([propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqual:@(connectionOrientation)] && [propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value] && (foundMatch == NO)) {
	    			foundMatch = YES;
	    			[adjacencyList removeObject:propertyArray];
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
    	for(NSArray *propertyArray in adjacencyList.objectEnumerator.allObjects) {
    		if([propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node1]) {
    			if([propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(connectionOrientation)] && [propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value] && (foundMatch == NO)) {
    				foundMatch = YES;
    				[adjacencyList removeObject:propertyArray];
    				[self decrementDegreeOfNode:node2];
	    			[self decrementDegreeOfNode:node1];
	    			if(directed) {
	    				if([propertyArray[kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) {
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

    for(NSArray *propertyArray in adjacencyList1.objectEnumerator.allObjects) {
		if([propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node2] && [propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(connectionOrientation)] && [propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value]) {
			[adjacencyList1 removeObject:propertyArray];
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

    for(NSArray *propertyArray in adjacencyList.objectEnumerator.allObjects) {
    	if([propertyArray[kDLA_CONNECTION_PROPERTIES_ADJACENT_NODE] isEqual:node2] && [propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_VALUE] isEqualToValue:value]) {
    		if(directed) {
    			if([propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(JVGraphConnectionOrientationDirected)] && [propertyArray[kDLA_CONNECTION_PROPERTIES_NODE_ORIENTATION] isEqualToNumber:@(JVGraphNodeOrientationInitial)]) return YES;
    		} else {
    			if([propertyArray[kDLA_CONNECTION_PROPERTIES_CONNECTION_ORIENTATION] isEqualToNumber:@(JVGraphConnectionOrientationUndirected)]) return YES;
    		}
    	}
    }

    return NO;
}

- (NSNumber *)degreeOfNode:(id)node {
	return _nodeInfoDictionary[node][kDLA_NODE_KEY_DEGREE];
}

- (NSUInteger)directedConnectionCount {
	return _directedConnectionCount;
}

- (NSNumber *)indegreeOfNode:(id)node {
	return _nodeInfoDictionary[node][kDLA_NODE_KEY_INDEGREE];
}

- (NSUInteger)nodeCount {
	return [_nodeDictionary count];
}

- (NSNumber *)outdegreeOfNode:(id)node {
	return _nodeInfoDictionary[node][kDLA_NODE_KEY_OUTDEGREE];
}

- (NSUInteger)undirectedConnectionCount {
	return _undirectedConnectionCount;
}

- (NSUInteger)uniqueIncidenceCount {
	return _uniqueIncidenceCount;
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

- (void)updateDegreeOfNode:(id)node withAmount:(NSUInteger)amount {
	_nodeInfoDictionary[node][kDLA_NODE_KEY_DEGREE] = @(((NSNumber *)_nodeInfoDictionary[node][kDLA_NODE_KEY_DEGREE]).integerValue + amount);
}

- (void)updateIndegreeOfNode:(id)node withAmount:(NSUInteger)amount {
	_nodeInfoDictionary[node][kDLA_NODE_KEY_INDEGREE] = @(((NSNumber *)_nodeInfoDictionary[node][kDLA_NODE_KEY_INDEGREE]).integerValue + amount);
}

- (void)updateOutdegreeOfNode:(id)node withAmount:(NSUInteger)amount {
	_nodeInfoDictionary[node][kDLA_NODE_KEY_OUTDEGREE] = @(((NSNumber *)_nodeInfoDictionary[node][kDLA_NODE_KEY_OUTDEGREE]).integerValue + amount);
}

@end