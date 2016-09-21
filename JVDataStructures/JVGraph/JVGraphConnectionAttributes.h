#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JVGraphConnectionAttributes : NSObject<NSCopying>

@property(nonatomic, strong) id adjacentNode;
@property(nonatomic, assign, getter=isDirected) BOOL directed;
@property(nonatomic, assign, getter=isInitialNode) BOOL initialNode;
@property(nonatomic, readonly, getter=isTerminalNode) BOOL terminalNode;
@property(nonatomic, readonly, getter=isUndirected) BOOL undirected;
@property(nonatomic, strong) NSValue *value;

@end

@interface JVGraphConnectionAttributes (JVExtendedGraphConnectionAttributes)

+ (instancetype)attributesWithAdjacentNode:(id)node directed:(BOOL)isDirected initialNode:(BOOL)isInitialNode value:(NSValue *)value;
- (instancetype)initWithAdjacentNode:(id)node directed:(BOOL)isDirected initialNode:(BOOL)isInitialNode value:(NSValue *)value;

@end

NS_ASSUME_NONNULL_END