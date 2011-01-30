#import "NSObject+TCTableModel.h"

@implementation NSObject (TCTableModel)

+ (id)decodeFromTC:(NSString *)str {
    return nil;
}

- (NSString *)encodeForTC {
    return [NSString string];
}

@end

@implementation NSString (TCTableModel)

+ (id)decodeFromTC:(NSString *)str {
    return str;
}

- (NSString *)encodeForTC {
    return self;
}

@end
