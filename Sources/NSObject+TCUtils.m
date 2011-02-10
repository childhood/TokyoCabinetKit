#import "TCInternal.h"
#import "NSObject+TCUtils.h"
#import "NSObject+TCCoding.h"

@implementation NSObject (TCUtils)

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

- (NSData *)dataFromObject:(id)object {
    if ([object isKindOfClass:[NSString class]])
        return [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
    else
        return [[object encodeForTC] dataUsingEncoding:NSUTF8StringEncoding];
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
