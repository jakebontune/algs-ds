#import <Foundation/Foundation.h>

@interface JVStack<ElementType> : NSObject

@property (readonly) NSUInteger count;

@property (nonatomic, readonly, getter=isEmpty) BOOL empty;

+ (instancetype)stack;
+ (instancetype)stackWithElement:(id)element;

- (instancetype)initWithElement:(ElementType)element;

- (void)push:(ElementType)element;
- (ElementType)pop;
- (ElementType)peek;

@end
