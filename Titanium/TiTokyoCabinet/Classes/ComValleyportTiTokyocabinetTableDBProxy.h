#import "TiProxy.h"
#import <TokyoCabinet/TokyoCabinet.h>

@interface ComValleyportTiTokyocabinetTableDBProxy : TiProxy {
@private
    TCTableDB *tdb;
}

@property (nonatomic, retain) TCTableDB *tdb;

@property (nonatomic, readonly) NSNumber *ecode;
@property (nonatomic, readonly) NSString *errorMessage;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSNumber *count;
@property (nonatomic, readonly) NSNumber *size;

+ (id)db;
+ (id)dbWithFile:(NSString *)file mode:(int)mode;

- (id)init;
- (id)initWithFile:(NSString *)file mode:(int)mode;

- (id)open:(id)args;
- (id)close:(id)args;
- (id)ecode;
- (id)errorMessage;
- (id)errorMessage:(id)arg;
- (id)setMutex:(id)args;
- (id)tune:(id)args;
- (id)setCache:(id)args;
- (id)setXmsiz:(id)arg;
- (id)setDfunit:(id)arg;
- (void)set:(id)args;
//- (void)setFromZeroSeparatedData:(id)args;
//- (void)setFromTabSeparatedString:(id)args;
- (void)cat:(id)args;
//- (void)catFromZeroSeparatedData:(id)args;
//- (void)catFromTabSeparatedString:(id)args;
- (void)remove:(id)args;
- (id)get:(id)args;
//- (id)zeroSeparatedData:(id)args;
//- (id)tabSeparatedString:(id)args;
- (id)mapSize:(id)args;
- (id)forwardMatchingKeys:(id)args;
- (void)sync:(id)args;
- (id)optimize:(id)args;
- (void)removeAll:(id)args;
- (id)copy:(id)args;
- (id)beginTransaction:(id)args;
- (id)commitTransaction:(id)args;
- (id)abortTransaction:(id)args;
- (id)path;
- (id)count;
- (id)size;
- (id)setIndex:(id)args;
- (id)removeIndex:(id)args;
- (id)optimizeIndex:(id)args;
- (id)generateUniqueId:(id)args;
- (id)metaSearch:(id)args;

@end
