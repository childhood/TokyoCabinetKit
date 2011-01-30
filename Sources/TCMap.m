#import "TCInternal.h"
#import "TCMap.h"
#import "TCList.h"
#import "NSObject+TCUtils.h"

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
    NSMutableString *str = [NSMutableString string];
    NSString *key;

    [self iteratorInit];
    while ((key = [self iteratorNext])) {
        if (str.length > 0) [str appendString:@", "];
        [str appendFormat:@"<%@: %@>", key, [self objectForKey:key]];
    }

    return [NSString stringWithFormat:@"<TCMap: %@>", str];
}

#pragma mark Public Methods

- (void)setObject:(id)value forKey:(id)key {
    [self setObject:value forKey:key keep:NO];
}

- (void)setObject:(id)value forKey:(id)key keep:(BOOL)keep {
    NSData *keyData = [self dataFromKey:key];
    NSData *valueData = [self dataFromObject:value];
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

- (void)setCString:(char *)value forKey:(id)key {
    [self setCString:value forKey:key keep:NO];
}

- (void)setCString:(char *)value forKey:(id)key keep:(BOOL)keep {
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

- (void)catObject:(id)value forKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    NSData *valueData = [self dataFromObject:value];
    tcmapputcat(
        map,
        [keyData bytes], [keyData length],
        [valueData bytes], [valueData length]
    );
}

- (void)removeObjectForKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    tcmapout(map, [keyData bytes], [keyData length]);
}

- (id)objectForKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    int size;
    const void *bytes = tcmapget(map, [keyData bytes], [keyData length], &size);
    return bytes ? [self objectFromBytes:bytes length:size] : nil;
}

- (BOOL)moveObjectForKey:(id)key toHead:(BOOL)head {
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

- (int)addInteger:(int)value forKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    return tcmapaddint(map, [keyData bytes], [keyData length], value);
}

- (double)addDouble:(double)value forKey:(id)key {
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

- (void)setValue:(id)value forKey:(NSString *)key {
    if (value)
        [self setObject:value forKey:key];
    else
        [self removeObjectForKey:key];
}

- (id)valueForKey:(NSString *)key {
    if ([[key substringToIndex:1] isEqualToString:@"@"])
        return [super valueForKey:[key substringFromIndex:1]];
    else
        return [self objectForKey:key];
}

@end
