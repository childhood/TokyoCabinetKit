#import <Foundation/Foundation.h>
#import <TokyoCabinet/tcutil.h>

@class TCList;

@interface TCMap : NSObject <NSCoding> {
@private
    TCMAP *map;
}

@property (nonatomic, readonly) TCMAP *map;
@property (nonatomic, readonly) uint64_t count;
@property (nonatomic, readonly) uint64_t size;

+ (id)map;
+ (id)mapWithNumber:(uint32_t)num;
+ (id)mapWithMap:(TCMap *)aMap;
+ (id)mapWithInternalMap:(TCMAP *)aMap;

- (id)initWithNumber:(uint32_t)num;
- (id)initWithMap:(TCMap *)aMap;
- (id)initWithInternalMap:(TCMAP *)aMap;

- (void)setObject:(id)value forKey:(id)key;
- (void)setObject:(id)value forKey:(id)key keep:(BOOL)keep;
- (void)setCString:(char *)value forKey:(id)key;
- (void)setCString:(char *)value forKey:(id)key keep:(BOOL)keep;
- (void)catObject:(id)value forKey:(id)key;
- (void)removeObjectForKey:(id)key;
- (id)objectForKey:(id)key;
- (BOOL)moveObjectForKey:(id)key toHead:(BOOL)head;
- (void)iteratorInit;
- (NSString *)iteratorNext;
- (uint64_t)count;
- (uint64_t)size;
- (TCList *)allKeys;
- (TCList *)allValues;
- (int)addInteger:(int)value forKey:(id)key;
- (double)addDouble:(double)value forKey:(id)key;
- (void)removeAllObjects;

@end
