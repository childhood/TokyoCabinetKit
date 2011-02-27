#import <Foundation/Foundation.h>
#import <TokyoCabinet/tctdb.h>
#import <TokyoCabinet/TCMap.h>
#import <TokyoCabinet/TCList.h>
#import <TokyoCabinet/TCTableDBQuery.h>

typedef enum {
    TCTableDBOpenModeWriter   = TDBOWRITER,
    TCTableDBOpenModeReader   = TDBOREADER,
    TCTableDBOpenModeCreate   = TDBOCREAT,
    TCTableDBOpenModeTruncate = TDBOTRUNC,
    TCTableDBOpenModeSync     = TDBOTSYNC,
    TCTableDBOpenModeNoLock   = TDBONOLCK,
    TCTableDBOpenModeLock     = TDBOLCKNB
} TCTableDBOpenMode;

typedef enum {
    TCTableDBIndexLexical = TDBQONUMDESC,
    TCTableDBIndexDecimal = TDBITDECIMAL,
    TCTableDBIndexToken   = TDBITTOKEN,
    TCTableDBIndexQGram   = TDBITQGRAM
} TCTableDBIndexType;

typedef enum {
    TCTableDBOptionLarge   = TDBTLARGE,    /* use 64-bit bucket array */
    TCTableDBOptionDeflate = TDBTDEFLATE,  /* compress each page with Deflate */
    TCTableDBOptionBzip    = TDBTBZIP,     /* compress each record with BZIP2 */
    TCTableDBOptionTCBS    = TDBTTCBS,     /* compress each page with TCBS */
    TCTableDBOptionExCodec = TDBTEXCODEC   /* compress each record with outer functions */
} TCTableDBOption;

@interface TCTableDB : TCObject {
@private
    TCTDB *tdb;
}

@property (nonatomic, readonly) TCTDB *tdb;
@property (nonatomic, readonly) int ecode;
@property (nonatomic, readonly) NSString *errorMessage;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) uint64_t count;
@property (nonatomic, readonly) uint64_t size;

+ (id)db;
+ (id)dbWithFile:(NSString *)file;
+ (id)dbWithFile:(NSString *)file mode:(int)mode;

- (id)init;
- (id)initWithFile:(NSString *)file;
- (id)initWithFile:(NSString *)file mode:(int)mode;

- (int)open:(NSString *)file;
- (int)open:(NSString *)file mode:(int)mode;
- (int)close;
- (int)ecode;
- (NSString *)errorMessage;
- (NSString *)errorMessage:(int)ecode;
- (BOOL)setMutex;
- (BOOL)tuneBnum:(int64_t)bnum apow:(int8_t)apow fpow:(int8_t)fpow opts:(uint8_t)opts;
- (BOOL)setCacheRcnum:(int32_t)rcnum lcnum:(int32_t)lcnum ncnum:(int32_t)ncnum;
- (BOOL)setXmsiz:(int64_t)xmsiz;
- (BOOL)setDfunit:(int32_t)dfunit;
- (void)setMap:(TCMap *)cols forKey:(id)key;
- (void)setMap:(TCMap *)cols forKey:(id)key keep:(BOOL)keep;
- (void)setMapFromZeroSeparatedData:(NSData *)data forKey:(id)key;
- (void)setMapFromZeroSeparatedData:(NSData *)data forKey:(id)key keep:(BOOL)keep;
- (void)setMapFromTabSeparatedString:(NSString *)str forKey:(id)key;
- (void)setMapFromTabSeparatedString:(NSString *)str forKey:(id)key keep:(BOOL)keep;
- (void)catMap:(TCMap *)cols forKey:(id)key;
- (void)catMapFromZeroSeparatedData:(NSData *)data forKey:(id)key;
- (void)catMapFromTabSeparatedString:(NSString *)str forKey:(id)key;
- (void)removeObjectForKey:(id)key;
- (TCMap *)mapForKey:(id)key;
- (NSData *)zeroSeparatedDataForKey:(id)key;
- (NSString *)tabSeparatedStringForKey:(id)key;
- (int)mapSizeForKey:(id)key;
- (void)iteratorInit;
- (NSData *)iteratorNextKeyData;
- (NSString *)iteratorNextKeyString;
- (TCMap *)iteratorNextMap;
- (TCList *)forwardMatchingKeys:(id)key max:(int)max;
- (int)addInteger:(int)value forKey:(id)key;
- (double)addDouble:(double)value forKey:(id)key;
- (void)sync;
- (BOOL)optimizeBnum:(int64_t)bnum apow:(int8_t)apow fpow:(int8_t)fpow opts:(uint8_t)opts;
- (void)removeAllObjects;
- (BOOL)copyToFile:(NSString *)file;
- (BOOL)beginTransaction;
- (BOOL)commitTransaction;
- (BOOL)abortTransaction;
- (NSString *)path;
- (uint64_t)count;
- (uint64_t)size;
- (BOOL)setIndex:(TCTableDBIndexType)type forColumn:(NSString *)name;
- (BOOL)setIndex:(TCTableDBIndexType)type forColumn:(NSString *)name keep:(BOOL)keep;
- (BOOL)removeIndex:(TCTableDBIndexType)type forColumn:(NSString *)name;
- (BOOL)optimizeIndexForColumn:(NSString *)name;
- (int64_t)generateUniqueId;
- (TCList *)metaSearch:(NSArray *)queries type:(int)type;

@end
