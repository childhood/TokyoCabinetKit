#import "NSObject+TokyoCabinet.h"

@implementation NSObject (TokyoCabinet)

+ (id)decodeFromTC:(NSString *)str {
    return nil;
}

- (NSString *)encodeForTC {
    return [NSString string];
}

@end

@implementation NSString (TokyoCabinet)

+ (id)decodeFromTC:(NSString *)str {
    return str;
}

- (NSString *)encodeForTC {
    return self;
}

@end
