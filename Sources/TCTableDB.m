#import "TCInternal.h"
#import "TCTableDB.h"
#import "NSObject+TCUtils.h"

@implementation TCTableDB

@synthesize tdb;

#pragma mark NSObject

+ (id)dbWithFile:(NSString *)file {
    return [[[TCTableDB alloc] initWithFile:file] autorelease];
}

+ (id)dbWithFile:(NSString *)file mode:(int)mode {
    return [[[TCTableDB alloc] initWithFile:file mode:mode] autorelease];
}

- (id)initWithFile:(NSString *)file {
    if ((self = [super init])) {
        tdb = tctdbnew();
        if (!tctdbopen(tdb, [file UTF8String],
                       TCTableDBOpenModeWriter | TCTableDBOpenModeCreate)) {
            NSLog(@"tdb open error: %s\n", tctdberrmsg(self.ecode));
        }
    }
    return self;
}

- (id)initWithFile:(NSString *)file mode:(int)mode {
    if ((self = [super init])) {
        tdb = tctdbnew();
        if (!tctdbopen(tdb, [file UTF8String], mode)) {
            NSLog(@"tdb open error: %s\n", tctdberrmsg(self.ecode));
        }
    }
    return self;
}

- (void)dealloc {
    if (!tctdbclose(tdb)) {
        NSLog(@"tdb close error: %s\n", tctdberrmsg(self.ecode));
    }

    tctdbdel(tdb);
    tdb = NULL;

    [super dealloc];
}

- (NSString *)description {
    NSMutableString *str = [NSMutableString string];
    NSString *key;

    return [NSString stringWithFormat:@"<TCTableDB - record number: %llu file size: %llu>",
            [self count], [self size]];
}

#pragma mark Public Methods

- (int)ecode {
    return tctdbecode(tdb);
}

- (NSString *)errorMessage {
   return [self errorMessage:self.ecode];
}

- (NSString *)errorMessage:(int)code {
    return [NSString stringWithUTF8String:tctdberrmsg(code)];
}

- (BOOL)setMutex {
    return tctdbsetmutex(tdb);
}

- (BOOL)tuneBnum:(int64_t)bnum apow:(int8_t)apow fpow:(int8_t)fpow opts:(uint8_t)opts {
    return tctdbtune(tdb, bnum, apow, fpow, opts);
}

- (BOOL)setCacheRcnum:(int32_t)rcnum lcnum:(int32_t)lcnum ncnum:(int32_t)ncnum {
    return tctdbsetcache(tdb, rcnum, lcnum, ncnum);
}

- (BOOL)setXmsiz:(int64_t)xmsiz {
    return tctdbsetxmsiz(tdb, xmsiz);
}

- (BOOL)setDfunit:(int32_t)dfunit {
    return tctdbsetdfunit(tdb, dfunit);
}

- (void)setMap:(TCMap *)cols forKey:(id)key {
    [self setMap:cols forKey:key keep:NO];
}

- (void)setMap:(TCMap *)cols forKey:(id)key keep:(BOOL)keep {
    NSData *keyData = [self dataFromKey:key];
    if (keep)
        tctdbputkeep(tdb, [keyData bytes], [keyData length], cols.map);
    else
        tctdbput(tdb, [keyData bytes], [keyData length], cols.map);
}

- (void)setMapFromZeroSeparatedData:(NSData *)data forKey:(id)key {
    [self setMapFromZeroSeparatedData:data forKey:key keep:NO];
}

- (void)setMapFromZeroSeparatedData:(NSData *)data forKey:(id)key keep:(BOOL)keep {
    NSData *keyData = [self dataFromKey:key];
    if (keep) {
        tctdbputkeep2(
            tdb,
            [keyData bytes], [keyData length],
            [data bytes], [data length]
        );
    } else {
        tctdbput2(
            tdb,
            [keyData bytes], [keyData length],
            [data bytes], [data length]
        );
    }
}

- (void)setMapFromTabSeparatedString:(NSString *)str forKey:(id)key {
    [self setMapFromTabSeparatedString:str forKey:key keep:NO];
}

- (void)setMapFromTabSeparatedString:(NSString *)str forKey:(id)key keep:(BOOL)keep {
    if (keep)
        tctdbputkeep3(tdb, [key UTF8String], [str UTF8String]);
    else
        tctdbput3(tdb, [key UTF8String], [str UTF8String]);
}

- (void)catMap:(TCMap *)cols forKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    tctdbputcat(tdb, [keyData bytes], [keyData length], cols.map);
}

- (void)catMapFromZeroSeparatedData:(NSData *)data forKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    tctdbputcat2(
        tdb,
        [keyData bytes], [keyData length],
        [data bytes], [data length]
    );
}

- (void)catMapFromTabSeparatedString:(NSString *)str forKey:(id)key {
    tctdbputcat3(tdb, [key UTF8String], [str UTF8String]);
}

- (void)removeObjectForKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    tctdbout(tdb, [keyData bytes], [keyData length]);
}

- (TCMap *)mapForKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    TCMAP *map = tctdbget(tdb, [keyData bytes], [keyData length]);
    return map ? [TCMap mapWithInternalMap:map] : nil;
}

- (NSData *)zeroSeparatedDataForKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    int size;
    char *str = tctdbget2(tdb, [keyData bytes], [keyData length], &size);
    return str ? [NSData dataWithBytes:str length:size] : nil;
}

- (NSString *)tabSeparatedStringForKey:(id)key {
    char *str = tctdbget3(tdb, [key UTF8String]);
    return str ? [NSString stringWithUTF8String:str] : nil;
}

- (int)mapSizeForKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    return tctdbvsiz(tdb, [keyData bytes], [keyData length]);
}

- (void)iteratorInit {
    tctdbiterinit(tdb);
}

- (NSData *)iteratorNextKeyData {
    int size;
    const void *bytes = tctdbiternext(tdb, &size);
    return [NSData dataWithBytes:bytes length:size];
}

- (NSString *)iteratorNextKeyString {
    return [NSString stringWithUTF8String:tctdbiternext2(tdb)];
}

- (TCMap *)iteratorNextMap {
    return [TCMap mapWithInternalMap:tctdbiternext3(tdb)];
}

- (TCList *)forwardMatchingKeys:(id)key max:(int)max {
    NSData *keyData = [self dataFromKey:key];
    return [TCList listWithInternalList:tctdbfwmkeys(
        tdb, [keyData bytes], [keyData length], max
    )];
}

- (int)addInteger:(int)value forKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    return tctdbaddint(tdb, [keyData bytes], [keyData length], value);
}

- (double)addDouble:(double)value forKey:(id)key {
    NSData *keyData = [self dataFromKey:key];
    return tctdbadddouble(tdb, [keyData bytes], [keyData length], value);
}

- (void)sync {
    tctdbsync(tdb);
}

- (BOOL)optimizeBnum:(int64_t)bnum apow:(int8_t)apow fpow:(int8_t)fpow opts:(uint8_t)opts {
    return tctdboptimize(tdb, bnum, apow, fpow, opts);
}

- (void)removeAllObjects {
    tctdbvanish(tdb);
}

- (BOOL)copyToFile:(NSString *)file {
    return tctdbcopy(tdb, [file UTF8String]);
}

- (BOOL)beginTransaction {
    return tctdbtranbegin(tdb);
}

- (BOOL)commitTransaction {
    return tctdbtrancommit(tdb);
}

- (BOOL)abortTransaction {
    return tctdbtranabort(tdb);
}

- (NSString *)path {
    return [NSString stringWithUTF8String:tctdbpath(tdb)];
}

- (uint64_t)count {
    return tctdbrnum(tdb);
}

- (uint64_t)size {
    return tctdbfsiz(tdb);
}

- (BOOL)setIndex:(TCTableDBIndexType)type forColumn:(NSString *)name {
    return [self setIndex:type forColumn:name keep:NO];
}

- (BOOL)setIndex:(TCTableDBIndexType)type forColumn:(NSString *)name keep:(BOOL)keep {
    if (keep) type = type | TDBITKEEP;
    return tctdbsetindex(tdb, [name UTF8String], type);
}

- (BOOL)removeIndex:(TCTableDBIndexType)type forColumn:(NSString *)name {
    return tctdbsetindex(tdb, [name UTF8String], TDBITVOID);
}

- (BOOL)optimizeIndexForColumn:(NSString *)name {
    return tctdbsetindex(tdb, [name UTF8String], TDBITOPT);
}

- (int64_t)generateUniqueId {
    return tctdbgenuid(tdb);
}

- (TCList *)metaSearch:(NSArray *)queries type:(int)type {
    NSRange range = NSMakeRange(0, queries.count);
    TDBQRY **array = malloc(sizeof(TDBQRY *) * queries.count);
    for (NSInteger i = 0; i < queries.count; i++) {
        array[i] = [(TCTableDBQuery *)[queries objectAtIndex:i] query];
    }
    TCLIST *list = tctdbmetasearch(array, range.length, type);
    free(array);
    return [TCList listWithInternalList:list];
}

@end
