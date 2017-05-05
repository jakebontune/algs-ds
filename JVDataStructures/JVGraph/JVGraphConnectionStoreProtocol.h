#import <Foundation/Foundation.h>
#import "JVGraphConnectionAttributes.h"

@protocol JVGraphConnectionStoreProtocol
NS_ASSUME_NONNULL_BEGIN

@required

- (NSEnumerator<NSDictionary<id <NSCopying>, NSArray<JVGraphConnectionAttributes *> *> *> *)adjacencyEnumerator;
- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2
                        directed:(BOOL)directed
                           value:(NSValue *)value;
@property(nonatomic, readonly) NSUInteger connectionCount;
@property(nonatomic, readonly) NSUInteger nodesConnectedCount;
- (NSUInteger)degreeOfNode:(id)node;
@property(nonatomic, readonly) NSUInteger directedConnectionCount;
- (NSUInteger)indegreeOfNode:(id)node;
- (NSEnumerator *)nodeEnumerator;
- (NSUInteger)outdegreeOfNode:(id)node;
- (void)removeNode:(id)node;
- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value;
- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value;
- (NSSet *)setOfNeighborsOfNode:(id)node;
- (NSSet *)setOfNodesAdjacentFromNode:(id)node;
- (NSSet *)setOfNodesAdjacentToNode:(id)node;
@property(nonatomic, readonly) NSUInteger undirectedConnectionCount;
@property(nonatomic, readonly) NSUInteger uniqueConnectionCount;

NS_ASSUME_NONNULL_END

@end