#import <Foundation/Foundation.h>
#import <Foundation/NSKeyValueCoding.h>
#import <TokyoCabinet/TCObject.h>
#import <TokyoCabinet/TCTableDB.h>
#import <TokyoCabinet/TCCoding.h>

@interface TCTableModel : TCObject {
@private
    NSString *key;
    TCMap *map;
    BOOL modified;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) TCMap *map;
@property (nonatomic, readonly) BOOL modified;

+ (id)model;
+ (id)modelWithKey:(NSString *)aKey;
+ (TCTableDB *)tdb;
+ (void)close;
+ (NSString *)generateKey;
+ (id)findByKey:(NSString *)aKey;
+ (id)find:(id)val by:(NSString *)col;
+ (id)findString:(NSString *)val by:(NSString *)col;
+ (id)findBool:(BOOL)val by:(NSString *)col;
+ (id)findChar:(char)val by:(NSString *)col;
+ (id)findDouble:(double)val by:(NSString *)col;
+ (id)findFloat:(float)val by:(NSString *)col;
+ (id)findInt:(int)val by:(NSString *)col;
+ (id)findInteger:(NSInteger)val by:(NSString *)col;
+ (id)findLong:(long)val by:(NSString *)col;
+ (id)findLongLong:(long long)val by:(NSString *)col;
+ (id)findShort:(short)val by:(NSString *)col;
+ (id)findUnsignedChar:(unsigned char)val by:(NSString *)col;
+ (id)findUnsignedInt:(unsigned int)val by:(NSString *)col;
+ (id)findUnsignedInteger:(NSUInteger)val by:(NSString *)col;
+ (id)findUnsignedLong:(unsigned long)val by:(NSString *)col;
+ (id)findUnsignedLongLong:(unsigned long long)val by:(NSString *)col;
+ (id)findUnsignedShort:(unsigned short)val by:(NSString *)col;

+ (int)ecode;
+ (NSString *)errorMessage;
+ (NSString *)errorMessage:(int)ecode;
+ (BOOL)tuneBnum:(int64_t)bnum apow:(int8_t)apow fpow:(int8_t)fpow opts:(uint8_t)opts;
+ (BOOL)setCacheRcnum:(int32_t)rcnum lcnum:(int32_t)lcnum ncnum:(int32_t)ncnum;
+ (BOOL)setXmsiz:(int64_t)xmsiz;
+ (BOOL)setDfunit:(int32_t)dfunit;
+ (int)mapSizeForKey:(id)key;
+ (TCList *)forwardMatchingKeys:(id)key max:(int)max;
+ (void)sync;
+ (BOOL)optimizeBnum:(int64_t)bnum apow:(int8_t)apow fpow:(int8_t)fpow opts:(uint8_t)opts;
+ (void)removeAllObjects;
+ (BOOL)beginTransaction;
+ (BOOL)commitTransaction;
+ (BOOL)abortTransaction;
+ (NSString *)path;
+ (uint64_t)count;
+ (uint64_t)size;
+ (BOOL)setIndex:(TCTableDBIndexType)type forColumn:(NSString *)name;
+ (BOOL)setIndex:(TCTableDBIndexType)type forColumn:(NSString *)name keep:(BOOL)keep;
+ (BOOL)removeIndex:(TCTableDBIndexType)type forColumn:(NSString *)name;
+ (BOOL)optimizeIndexForColumn:(NSString *)name;
+ (int64_t)generateUniqueId;

+ (NSArray *)search:(TCTableDBQuery *)query;
+ (NSArray *)metaSearch:(NSArray *)queries type:(int)type;

- (id)init;
- (id)initWithKey:(NSString *)aKey;
- (void)assignKey;
- (void)save;

@end
