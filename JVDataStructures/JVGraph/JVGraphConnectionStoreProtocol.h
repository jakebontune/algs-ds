#import <Foundation/Foundation.h>

@protocol JVGraphConnectionStoreProtocol
@required
- (void)addNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value;
- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2
                           value:(NSValue *)value;
@property(readonly) NSUInteger connectionsCount;
@property(readonly) NSUInteger directedConnectionsCount;
@property(readonly) NSUInteger inDegreeCount;
- (instancetype)initWithNode:(id)node1
              adjacentToNode:(id)node2
                    directed:(BOOL)directed
                       value:(NSValue *)value;
@property(readonly) NSUInteger outDegreeCount;
- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value;
@property(readonly) NSUInteger undirectedConnectionsCount;

@end