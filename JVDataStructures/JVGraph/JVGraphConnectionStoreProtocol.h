#import <Foundation/Foundation.h>

@protocol JVGraphConnectionStoreProtocol
@required

NS_ASSUME_NONNULL_BEGIN

- (NSEnumerator<NSDictionary<id <NSCopying>, NSArray<NSDictionary *> *> *> *)adjacencyEnumerator;
- (BOOL)connectionExistsFromNode:(id)node1
                          toNode:(id)node2
                        directed:(BOOL)directed
                           value:(NSValue *)value;
@property(nonatomic, readonly) NSUInteger connectionCount;
@property(nonatomic, readonly) NSUInteger nodeCount;
- (NSNumber *)degreeOfNode:(id)node;
@property(nonatomic, readonly) NSUInteger directedConnectionCount;
- (NSNumber *)indegreeOfNode:(id)node;
- (instancetype)initWithNode:(id)node1
              adjacentToNode:(id)node2
                    directed:(BOOL)directed
                       value:(NSValue *)value;
- (NSNumber *)outdegreeOfNode:(id)node;
- (void)removeNode:(id)node;
- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value;
- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value;
@property(nonatomic, readonly) NSUInteger undirectedConnectionCount;
@property(nonatomic, readonly) NSUInteger uniqueIncidenceCount;

NS_ASSUME_NONNULL_END

@end