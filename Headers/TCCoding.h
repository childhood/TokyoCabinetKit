@protocol TCCoding <NSObject>

+ (id)decodeFromTC:(NSString *)str;
- (NSString *)encodeForTC;

@end
