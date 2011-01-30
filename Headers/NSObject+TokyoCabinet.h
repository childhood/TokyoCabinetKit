@interface NSObject (TokyoCabinet)

+ (id)decodeFromTC:(NSString *)str;
- (NSString *)encodeForTC;

@end
