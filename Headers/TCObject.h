#import <Foundation/Foundation.h>

@interface TCObject : NSObject {
}

- (NSData *)dataFromKey:(id)key;
- (NSData *)dataFromString:(NSString *)str;
- (id)objectFromData:(NSData *)data;
- (id)objectFromBytes:(const void *)bytes length:(NSInteger)size;
- (NSString *)stringFromData:(NSData *)data;

@end
