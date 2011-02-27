#import <Foundation/Foundation.h>
#import <TokyoCabinet/TCObject.h>
#import <TokyoCabinet/tcutil.h>

@class TCList;

@interface TCMap : TCObject <NSCoding, NSFastEnumeration> {
@private
    TCMAP *map;
}

@property (nonatomic, readonly) TCMAP *map;
@property (nonatomic, readonly) uint64_t count;
@property (nonatomic, readonly) uint64_t size;
@property (nonatomic, readonly) TCList *allKeys;
@property (nonatomic, readonly) TCList *allValues;

+ (id)map;
+ (id)mapWithNumber:(uint32_t)num;
+ (id)mapWithMap:(TCMap *)aMap;
+ (id)mapWithInternalMap:(TCMAP *)aMap;

- (id)initWithNumber:(uint32_t)num;
- (id)initWithMap:(TCMap *)aMap;
- (id)initWithInternalMap:(TCMAP *)aMap;

- (void)setObject:(NSString *)value forKey:(NSString *)key;
- (void)setObject:(NSString *)value forKey:(NSString *)key keep:(BOOL)keep;
- (void)setCString:(char *)value forKey:(NSString *)key;
- (void)setCString:(char *)value forKey:(NSString *)key keep:(BOOL)keep;
- (void)catObject:(NSString *)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (NSString *)objectForKey:(NSString *)key;
- (BOOL)moveObjectForKey:(NSString *)key toHead:(BOOL)head;
- (void)iteratorInit;
- (NSString *)iteratorNext;
- (uint64_t)count;
- (uint64_t)size;
- (TCList *)allKeys;
- (TCList *)allValues;
- (int)addInteger:(int)value forKey:(NSString *)key;
- (double)addDouble:(double)value forKey:(NSString *)key;
- (void)removeAllObjects;

- (void)setValue:(id)value forKey:(id)key;
- (id)valueForKey:(id)key;

+ (id)mapFromDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionary;

@end
