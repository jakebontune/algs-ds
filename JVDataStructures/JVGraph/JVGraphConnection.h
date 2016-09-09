#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JVGraphConnection : NSObject

@property(getter=isDirected) BOOL directed;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey value:(nullable NSValue *)value directed:(BOOL)isDirected NS_DESIGNATED_INITIALIZER;
@property(nonatomic, strong) id initialNodeKey;
@property(nullable, nonatomic, strong) id terminalNodeKey;
@property(nullable, nonatomic, strong) NSValue *value;

@end

@interface JVGraphConnection (JVExtendedGraphConnection)

// get creative

@end

@interface JVGraphConnection (JVGraphConnectionCreation)

+ (instancetype)connection;
+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey;
+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey directed:(BOOL)isDirected;
+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey;
+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey value:(nullable NSValue *)value directed:(BOOL)isDirected;
+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(id)terminalNodeKey value:(nullable NSValue *)value;
+ (instancetype)connectionWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey value:(nullable NSValue *)value directed:(BOOL)isDirected;

- (instancetype)initWithInitialNodeKey:(id)initialNodeKey;
- (instancetype)initWithInitialNodeKey:(id)initialNodeKey directed:(BOOL)isDirected;
- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey;
- (instancetype)initWithInitialNodeKey:(id)initialNodeKey value:(nullable NSValue *)value directed:(BOOL)isDirected;
- (instancetype)initWithInitialNodeKey:(id)initialNodeKey terminalNodeKey:(nullable id)terminalNodeKey value:(nullable NSValue *)value;

@end

NS_ASSUME_NONNULL_END