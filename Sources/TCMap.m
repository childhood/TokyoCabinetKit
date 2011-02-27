#import "TCInternal.h"
#import "TCMap.h"
#import "TCList.h"

@implementation TCMap

@synthesize map;

#pragma mark NSObject

+ (id)map {
    return [[[TCMap alloc] init] autorelease];
}

+ (id)mapWithNumber:(uint32_t)num {
    return [[[TCMap alloc] initWithNumber:num] autorelease];
}

+ (id)mapWithMap:(TCMap *)aMap {
    return [[[TCMap alloc] initWithMap:aMap] autorelease];
}

+ (id)mapWithInternalMap:(TCMAP *)aMap {
    return [[[TCMap alloc] initWithInternalMap:aMap] autorelease];
}

- (id)init {
    if ((self = [super init])) {
        map = tcmapnew();
    }
    return self;
}

- (id)initWithNumber:(uint32_t)num {
    if ((self = [super init])) {
        map = tcmapnew2(num);
    }
    return self;
}

- (id)initWithMap:(TCMap *)aMap {
    if ((self = [super init])) {
        map = tcmapdup(aMap.map);
    }
    return self;
}

- (id)initWithInternalMap:(TCMAP *)aMap {
    if ((self = [super init])) {
        map = aMap;
    }
    return self;
}

- (void)dealloc {
    if (map) {
        tcmapdel(map);
        map = NULL;
    }

    [super dealloc];
}

- (NSString *)description {
    //NSMutableString *str = [NSMutableString string];
    //[self iteratorInit];
    //while ((NSString *key = [self iteratorNext])) {
    //    if (str.length > 0) [str appendString:@", "];
    //    [str appendFormat:@"<%@: %@>", key, [self objectForKey:key]];
    //}
    //return [NSString stringWithFormat:@"<TCMap: %@>", str];

    return [NSString stringWithFormat:@"<TCMap: count: %d>", self.count];
}

#pragma mark Public Methods

- (void)setObject:(NSString *)value forKey:(NSString *)key {
    [self setObject:value forKey:key keep:NO];
}

- (void)setObject:(NSString *)value forKey:(NSString *)key keep:(BOOL)keep {
    NSData *keyData = [self dataFromKey:key];
    NSData *valueData = [self dataFromString:value];
    if (keep) {
        tcmapputkeep(
            map,
            [keyData bytes], [keyData length],
            [valueData bytes], [valueData length]
        );
    } else {
        tcmapput(
            map,
            [keyData bytes], [keyData length],
            [valueData bytes], [valueData length]
        );
    }
}

- (void)setCString:(char *)value forKey:(NSString *)key {
    [self setCString:value forKey:key keep:NO];
}

- (void)setCString:(char *)value forKey:(NSString *)key keep:(BOOL)keep {
    NSData *keyData = [self dataFromKey:key];
    if (keep) {
        tcmapputkeep(
            map,
            [keyData bytes], [keyData length],
            value, strlen(value)
        );
    } else {
        tcmapput(
            map,
            [keyData bytes], [keyData length],
            value, strlen(value)
        );
    }
}

- (void)catObject:(NSString *)value forKey:(NSString *)key {
    NSData *keyData = [self dataFromKey:key];
    NSData *valueData = [self dataFromString:value];
    tcmapputcat(
        map,
        [keyData bytes], [keyData length],
        [valueData bytes], [valueData length]
    );
}

- (void)removeObjectForKey:(NSString *)key {
    NSData *keyData = [self dataFromKey:key];
    tcmapout(map, [keyData bytes], [keyData length]);
}

- (NSString *)objectForKey:(NSString *)key {
    NSData *keyData = [self dataFromKey:key];
    int size;
    const void *bytes = tcmapget(map, [keyData bytes], [keyData length], &size);
    return bytes ? [self objectFromBytes:bytes length:size] : nil;
}

- (BOOL)moveObjectForKey:(NSString *)key toHead:(BOOL)head {
    NSData *keyData = [self dataFromKey:key];
    return tcmapmove(map, [keyData bytes], [keyData length], head);
}

- (void)iteratorInit {
    tcmapiterinit(map);
}

- (NSString *)iteratorNext {
    int size;
    const void *bytes = tcmapiternext(map, &size);
    return bytes ? [NSString stringWithUTF8String:bytes] : nil;
}

- (uint64_t)count {
    return tcmaprnum(map);
}

- (uint64_t)size {
    return tcmapmsiz(map);
}

- (TCList *)allKeys {
    return [TCList listWithInternalList:tcmapkeys(map)];
}

- (TCList *)allValues {
    return [TCList listWithInternalList:tcmapvals(map)];
}

- (int)addInteger:(int)value forKey:(NSString *)key {
    NSData *keyData = [self dataFromKey:key];
    return tcmapaddint(map, [keyData bytes], [keyData length], value);
}

- (double)addDouble:(double)value forKey:(NSString *)key {
    NSData *keyData = [self dataFromKey:key];
    return tcmapadddouble(map, [keyData bytes], [keyData length], value);
}

- (void)removeAllObjects {
    tcmapclear(map);
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        NSData *data = [decoder decodeObjectForKey:@"map"];
        map = tcmapload([data bytes], [data length]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    int size;
    void *bytes = tcmapdump(map, &size);
    NSData *data = [NSData dataWithBytes:bytes length:size];
    tcfree(bytes);
    [encoder encodeObject:data forKey:@"map"];
}

#pragma mark NSKeyValueCoding

- (void)setValue:(id)value forKey:(id)key {
    if (value)
        [self setObject:value forKey:key];
    else
        [self removeObjectForKey:key];
}

- (id)valueForKey:(id)key {
    if ([[key substringToIndex:1] isEqualToString:@"@"])
        return [super valueForKey:[key substringFromIndex:1]];
    else
        return [self objectForKey:key];
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len {
    if (state->state >= self.count)
        return 0;

    TCList *keys = self.allKeys;
    int count = 0;
    while (state->state < keys.count && count < len) {
        stackbuf[count] = [keys objectAtIndex:state->state];
        count += 1;
        state->state += 1;
    }

    state->itemsPtr = stackbuf;
    state->mutationsPtr = (unsigned long *)keys;

    return count;
}

#pragma mark Conversion

+ (id)mapFromDictionary:(NSDictionary *)dict {
    TCMap *map = [TCMap map];

    for (NSString *key in dict) {
        [map setObject:[dict objectForKey:key] forKey:key];
    }

    return map;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    tcmapiterinit(map);
    int keySize;
    const void *keyBytes;
    while ((keyBytes = tcmapiternext(map, &keySize))) {
        int valSize;
        const void *valBytes = tcmapget(map, keyBytes, keySize, &valSize);
        [dict setObject:[NSString stringWithUTF8String:valBytes]
                 forKey:[NSString stringWithUTF8String:keyBytes]];
    }

    return dict;
}

@end
