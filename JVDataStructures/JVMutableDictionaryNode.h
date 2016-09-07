#import <Foundation/Foundation.h>

@interface JVMutableDictionaryNode : NSObject

@property (nonatomic, copy) id key;
@property (nonatomic, strong) id element;
@property (nonatomic, strong) JVMutableDictionaryNode *next;

@end