#import "TokyoCabinet/NSObject+TCTableModel.h"
#import "TokyoCabinet/TCTableModel.h"

@protocol TCTableModel <NSObject>

+ (id)decodeFromTC:(NSString *)str;
- (NSString *)encodeForTC;

@end
