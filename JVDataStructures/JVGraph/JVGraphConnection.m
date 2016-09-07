#import "JVGraphConnection.h"

@implementation JVGraphConnection {
    id _initialNodeKey;
    id _terminalNodeKey;
    NSValue *_value;
    BOOL _directed;
}

#pragma mark - Creating a Graph Connection

+ (instancetype)connection {
    return [[JVGraphConnection alloc] init];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(NSValue *)value directed:(BOOL)isDirected {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:value directed:isDirected];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(NSValue *)value {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:value directed:NO];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey value:(NSValue *)value directed:(BOOL)isDirected {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:value directed:isDirected];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:nil directed:NO];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey directed:(BOOL)isDirected {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:nil directed:isDirected];
}

+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey {
    return [[JVGraphConnection alloc] initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:nil directed:NO];
}

#pragma mark - Initializing a Graph Connection

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(NSValue *)value directed:(BOOL)isDirected {
    if(self = [super init]) {
        _initialNodeKey = initialNodeKey;
        _terminalNodeKey = terminalNodeKey;
        value = value;
        _directed = isDirected;
    }

    return self;
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(NSValue *)value {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:value directed:NO];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey value:(NSValue *)value directed:(BOOL)isDirected {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:value directed:isDirected];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:terminalNodeKey value:nil directed:NO];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey directed:(BOOL)isDirected; {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:nil directed:isDirected];
}

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey {
    return [self initWithInitialNodeKey:initialNodeKey terminalNodeKey:nil value:nil directed:NO];
}

#pragma mark - Querying a Graph Connection

- (BOOL)isDirected {
    return _directed;
}

- (void)setDirected:(BOOL)isDirected {
    _directed = isDirected;
}

- (id)initialNodeKey {
    return _initialNodeKey;
}

- (void)setInitialNodeKey:(id)initialNodeKey {
    _initialNodeKey = initialNodeKey;
}

- (id)terminalNodeKey {
    return _terminalNodeKey;
}

- (void)setTerminalNodeKey:(id)terminalNodeKey {
    _terminalNodeKey = terminalNodeKey;
}

- (NSValue *)value {
    return _value;
}

- (void)setValue:(NSValue *)value {
    _value = value;
}

@end