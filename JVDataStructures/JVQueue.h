#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JVQueue<ElementType> : NSObject

+ (instancetype)queue;
+ (instancetype)queueWithElement:(id)element;

- (instancetype)initWithElement:(ElementType)element;

- (void)enqueue:(ElementType)element;
- (ElementType)dequeue;

- (ElementType)peek;

@property (readonly) NSUInteger count;
@property (readonly, getter=isEmpty) BOOL empty;

@end

NS_ASSUME_NONNULL_END