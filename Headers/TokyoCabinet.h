#import "TokyoCabinet/NSObject+TokyoCabinet.h"
#import "TokyoCabinet/TCModel.h"

@protocol TCTableModel <NSObject>

+ (id)decodeFromTC:(NSString *)str;
- (NSString *)encodeForTC;

@end
