#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, JVGraphConnectionOrientationOptions) {
    JVGraphConnectionOrientationDirected = 5 << 0, // 0000 0101
    JVGraphConnectionOrientationUndirected = 5 << 1, // 0000 1010
};

typedef NS_OPTIONS(NSUInteger, JVGraphNodeOrientationOptions) {
    JVGraphNodeOrientationInitial = 3 << 0, // 0000 0011
    JVGraphNodeOrientationTerminal = 3 << 2, // 0000 1100
};

@protocol JVGraphConnectionStoreProtocol
@required

NS_ASSUME_NONNULL_BEGIN

- (NSEnumerator<NSDictionary<id <NSCopying>, NSArray<NSDictionary *> *> *> *)adjacencyEnumerator;
- (BOOL)connectionExistsFromNode:(id)node1 toNode:(id)node2;
- (BOOL)connectionExistsFromNode:(id)node1 toNode:(id)node2 value:(NSValue *)value;
@property(readonly) NSUInteger connectionCount;
- (NSNumber *)degreeOfNode:(id)node;
@property(readonly) NSUInteger directedConnectionCount;
@property(readonly) NSUInteger distinctIncidenceCount;
- (NSNumber *)inDegreeofNode:(id)node;
- (instancetype)initWithNode:(id)node1 adjacentToNode:(id)node2;
- (instancetype)initWithNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed;
- (instancetype)initWithNode:(id)node1
              adjacentToNode:(id)node2
                    directed:(BOOL)directed
                       value:(NSValue *)value;
- (NSNumber *)outDegreeOfNode:(id)node;
- (void)removeNode:(id)node;
- (void)removeNode:(id)node1 adjacentToNode:(id)node2;
- (void)removeNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed;
- (void)removeNode:(id)node1
    adjacentToNode:(id)node2
          directed:(BOOL)directed
             value:(NSValue *)value;
- (void)setNode:(id)node1 adjacentToNode:(id)node2;
- (void)setNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed;
- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value;
+ (instancetype)store;
+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2;
+ (instancetype)storeWithNode:(id)node1 adjacentToNode:(id)node2 directed:(BOOL)directed;
+ (instancetype)storeWithNode:(id)node1
               adjacentToNode:(id)node2
                     directed:(BOOL)directed
                        value:(NSValue *)value;
@property(readonly) NSUInteger undirectedConnectionCount;

NS_ASSUME_NONNULL_END

@end