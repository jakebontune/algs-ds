#import "JVGraphConnectionAttributes.h"

@implementation JVGraphConnectionAttributes {
	id _adjacentNode;
	BOOL _isDirected;
	BOOL _isInitialNode;
	NSValue *_value;
}

#pragma mark - Creating Connection Attributes

+ (instancetype)attributes {
	return [[JVGraphConnectionAttributes alloc] init];
}

+ (instancetype)attributesWithAdjacentNode:(id)node directed:(BOOL)isDirected initialNode:(BOOL)isInitialNode value:(NSValue *)value {
	return [[JVGraphConnectionAttributes alloc] initWithAdjacentNode:node directed:isDirected initialNode:isInitialNode value:value];
}

#pragma mark - Initializing Connection Attributes

- (instancetype)initWithAdjacentNode:(id)node directed:(BOOL)isDirected initialNode:(BOOL)isInitialNode value:(NSValue *)value {
	_adjacentNode = node;
	_isDirected = isDirected;
	_isInitialNode = isInitialNode;
	_value = value;
}

#pragma mark - Querying for Connection Attributes

- (id)adjacentNode {
	return _adjacentNode;
}

- (BOOL)isDirected {
	return _isDirected;
}

- (BOOL)isInitialNode {
	return _isInitialNode;
}

- (BOOL)isTerminalNode {
	return !_isInitialNode;
}

- (BOOL)isUndirected {
	return !_isDirected;
}

- (NSValue *)value {
	return _value;
}

- (void)setAdjacentNode:(id)node {
	_adjacentNode = node;
}

- (void)setDirected:(BOOL)isDirected {
	_isDirected = isDirected;
}

- (void)setInitialNode:(BOOL)isInitialNode {
	_isInitialNode = isInitialNode;
}

- (void)setValue:(NSValue *)value {
	_value = value;
}

#pragma mark - NSObject Protocol

- (BOOL)isEqual:(JVGraphConnectionAttributes *)attributes {
	return ([_adjacentNode isEqual:attributes.adjacentNode]) && (_isDirected == attributes.isDirected) && (_isInitialNode == attributes.isInitialNode) && ([_value isEqualToValue:value]) && ([self hash] == [attributes hash]);
}

#pragma mark - NSCopying Protocol

- (JVGraphConnectionAttributes *)copyWithZone:(NSZone *)zone {
	JVGraphConnectionAttributes *attributes = [JVGraphConnectionAttributes attributesWithAdjacentNode:_adjacentNode directed:_isDirected initialNode:_isInitialNode value:_value];
	return attributes;
}

@end