@interface NSObject (TCTableModel)

+ (id)decodeFromTC:(NSString *)str;
- (NSString *)encodeForTC;

@end
