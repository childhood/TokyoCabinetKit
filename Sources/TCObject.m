#import "TCInternal.h"
#import "NSString+TCCoding.h"
#import "TCObject.h"

@implementation TCObject

- (NSData *)dataFromKey:(id)key {
    NSData *data;
    if ([key isKindOfClass:[NSString class]]) {
        data = [key dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        NSUInteger hash = [key hash];
        data = [NSData dataWithBytes:&hash length:sizeof(NSUInteger)];
    }
    return data;
}

- (NSData *)dataFromString:(NSString *)str {
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)objectFromData:(NSData *)data {
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (id)objectFromBytes:(const void *)bytes length:(NSInteger)size {
    NSData *data = [NSData dataWithBytes:bytes length:size];
    return [self objectFromData:data];
}

- (NSString *)stringFromData:(NSData *)data {
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

@end
