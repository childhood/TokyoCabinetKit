#import "TiProxy.h"
#import <TokyoCabinet/TokyoCabinet.h>

@interface ComValleyportTiTokyocabinetTableDBProxy : TiProxy {
@private
    TCTableDB *tdb;
}

@property (nonatomic, retain) TCTableDB *tdb;

+ (id)db;
+ (id)dbWithFile:(NSString *)file mode:(int)mode;

- (id)init;
- (id)initWithFile:(NSString *)file mode:(int)mode;

- (id)open:(id)args;
- (id)close:(id)args;

@end
