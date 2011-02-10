#import "NSObject+TCCoding.h"

@implementation NSString (TCCoding)

+ (id)decodeFromTC:(NSString *)str {
    return str;
}

- (NSString *)encodeForTC {
    return self;
}

@end
