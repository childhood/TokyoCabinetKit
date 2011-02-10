#import <TokyoCabinet/TCCoding.h>

@interface NSString (TCCoding) <TCCoding>

+ (id)decodeFromTC:(NSString *)str;
- (NSString *)encodeForTC;

@end
