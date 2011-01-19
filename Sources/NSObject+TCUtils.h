#import <Foundation/Foundation.h>

@interface NSObject (TCUtils)

- (NSData *)dataFromKey:(id)key;
- (NSData *)dataFromString:(NSString *)str;
- (NSData *)dataFromObject:(id)object;
- (id)objectFromData:(NSData *)data;
- (id)objectFromBytes:(const void *)bytes length:(NSInteger)size;
- (NSString *)stringFromData:(NSData *)data;

@end
