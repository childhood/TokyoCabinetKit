#import "ComValleyportTiTokyocabinetTableDBProxy.h"
#import "TiUtils.h"

@implementation ComValleyportTiTokyocabinetTableDBProxy

@synthesize tdb;

#pragma mark Internal Methods

- (NSString *)dbDir {
    NSString *rootDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [[rootDir stringByAppendingPathComponent:@"database"] retain];
    NSFileManager *fm = [NSFileManager defaultManager];

    BOOL isDirectory;
    BOOL exists = [fm fileExistsAtPath:dbPath isDirectory:&isDirectory];

    if (!exists) {
        [fm createDirectoryAtPath:dbPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }

    return [dbPath autorelease];
}

- (NSString *)dbPath:(NSString *)name {
    NSString *dbDir = [self dbDir];
    return [dbDir stringByAppendingPathComponent:name];
}

#pragma mark Class Methods

+ (id)db {
    return [[[[self class] alloc] init] autorelease];
}

+ (id)dbWithFile:(NSString *)file mode:(int)mode {
    return [[[[self class] alloc]
             initWithFile:file mode:mode] autorelease];
}

#pragma mark NSObject

- (id)init {
    if ((self = [super init])) {
        self.tdb = [TCTableDB db];
    }
    return self;
}

- (id)initWithFile:(NSString *)file mode:(int)mode {
    if ((self = [super init])) {
        self.tdb = [TCTableDB dbWithFile:[self dbPath:file] mode:mode];
    }
    return self;
}

- (void)dealloc {
    [tdb release];

    [super dealloc];
}

#pragma mark Public Methods

- (id)open:(id)args {
    ENSURE_ARG_COUNT((NSArray *)args, 1);
    id arg = [(NSArray *)args objectAtIndex:0];
    ENSURE_STRING(arg);
    NSString *file = [self dbPath:[TiUtils stringValue:arg]];

    int mode;
    if ([(NSArray *)args count] >= 2) {
        arg = [args objectAtIndex:1];
        ENSURE_TYPE(arg, NSNumber);
        mode = [TiUtils intValue:arg];
    } else {
        mode = TCTableDBOpenModeReader |
               TCTableDBOpenModeWriter |
               TCTableDBOpenModeCreate;
    }
    NSLog(@"[INFO] tdb open: %@ mode: %d", file, mode);

    return NUMINT([tdb open:file mode:mode]);
}

- (id)close:(id)args {
    return NUMINT([tdb close]);
}

- (id)ecode {
    return NUMINT([tdb ecode]);
}

- (id)errorMessage {
    return [tdb errorMessage];
}

- (id)errorMessage:(id)arg {
    ENSURE_TYPE_OR_NIL(arg, NSNumber);
    return arg ? [tdb errorMessage:[TiUtils intValue:arg]] : [tdb errorMessage];
}

- (id)setMutex:(id)args {
    return NUMBOOL([tdb setMutex]);
}

- (id)tune:(id)args {
    ENSURE_DICT(args);

    id obj;
    obj = [args objectForKey:@"bnum"];
    int bnum = obj ? [TiUtils intValue:obj] : -1;

    obj = [args objectForKey:@"apow"];
    int apow = obj ? [TiUtils intValue:obj] : -1;

    obj = [args objectForKey:@"fpow"];
    int fpow = obj ? [TiUtils intValue:obj] : -1;

    obj = [args objectForKey:@"opts"];
    int opts = obj ? [TiUtils intValue:obj] : -1;

    NSLog(@"[INFO] tdb tune bnum: %d apow: %d fpow: %d opts: %d", bnum, apow, fpow, opts);

    return NUMBOOL([tdb tuneBnum:bnum apow:apow fpow:fpow opts:opts]);
}

- (id)setCache:(id)args {
    ENSURE_DICT(args);

    id obj;
    obj = [args objectForKey:@"rcnum"];
    int rcnum = obj ? [TiUtils intValue:obj] : -1;

    obj = [args objectForKey:@"lcnum"];
    int lcnum = obj ? [TiUtils intValue:obj] : -1;

    obj = [args objectForKey:@"ncnum"];
    int ncnum = obj ? [TiUtils intValue:obj] : -1;

    NSLog(@"[INFO] tdb setCache rcnum: %d lcnum: %d, ncnum: %d", rcnum, lcnum, ncnum);

    return NUMBOOL([tdb setCacheRcnum:rcnum lcnum:lcnum ncnum:ncnum]);
}

- (id)setXmsiz:(id)arg {
    ENSURE_TYPE(arg, NSNumber);

    int xmsiz = [TiUtils intValue:arg];
    NSLog(@"[INFO] tdb setXmsiz: %d", xmsiz);

    return NUMBOOL([tdb setXmsiz:xmsiz]);
}

- (id)setDfunit:(id)arg {
    ENSURE_TYPE(arg, NSNumber);

    int dfunit = [TiUtils intValue:arg];
    NSLog(@"[INFO] tdb setDfunit: %d", dfunit);

    return NUMBOOL([tdb setDfunit:dfunit]);
}

- (void)set:(id)args {
    NSString *key;
    NSDictionary *dict;
    BOOL keep = NO;

    if ([(NSArray *)args count] == 1) { // value only
        ENSURE_DICT(args);
        dict = args;
        key = [NSString stringWithFormat:@"%lld", [tdb generateUniqueId]];
    } else if ([(NSArray *)args count] >= 2) {
        key = [TiUtils stringValue:[args objectAtIndex:0]];
        ENSURE_STRING(key);
        dict = [args objectAtIndex:1];
        ENSURE_DICT(dict);

        if ([(NSArray *)args count] >= 3)
            keep = [TiUtils boolValue:[args objectAtIndex:2]];
    }

    [tdb setMap:[TCMap mapFromDictionary:dict] forKey:key keep:keep];
}

//- (void)setFromZeroSeparatedData:(id)args {
//}

//- (void)setFromTabSeparatedString:(id)args {
//}

- (void)cat:(id)args {
}

//- (void)catFromZeroSeparatedData:(id)args {
//}

//- (void)catFromTabSeparatedString:(id)args {
//}

- (void)remove:(id)args {
}

- (id)get:(id)args {
    ENSURE_ARG_COUNT((NSArray *)args, 1);
    id arg = [args objectAtIndex:0];
    return [[tdb mapForKey:[TiUtils stringValue:[args objectAtIndex:0]]] dictionary];
}

//- (id)zeroSeparatedData:(id)args {
//    return @"not implemented yet";
//}

//- (id)tabSeparatedString:(id)args {
//    return @"not implemented yet";
//}

- (id)mapSize:(id)args {
    return @"not implemented yet";
}

- (id)forwardMatchingKeys:(id)args {
    return @"not implemented yet";
}

- (void)sync:(id)args {
}

- (id)optimize:(id)args {
    return @"not implemented yet";
}

- (void)removeAll:(id)args {
}

- (id)copy:(id)args {
    return @"not implemented yet";
}

- (id)beginTransaction:(id)args {
    return @"not implemented yet";
}

- (id)commitTransaction:(id)args {
    return @"not implemented yet";
}

- (id)abortTransaction:(id)args {
    return @"not implemented yet";
}

- (id)path {
    return [tdb path];
}

- (id)count {
    return NUMINT([tdb count]);
}

- (id)size {
    return NUMINT([tdb size]);
}

- (id)setIndex:(id)args {
    return @"not implemented yet";
}

- (id)removeIndex:(id)args {
    return @"not implemented yet";
}

- (id)optimizeIndex:(id)args {
    return @"not implemented yet";
}

- (id)generateUniqueId:(id)args {
    return NUMINT([tdb generateUniqueId]);
}

- (id)metaSearch:(id)args {
    return @"not implemented yet";
}

@end
