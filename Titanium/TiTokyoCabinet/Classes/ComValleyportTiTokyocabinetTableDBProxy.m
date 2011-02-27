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
    ENSURE_ARG_COUNT(args, 1);
    id arg = [args objectAtIndex:0];
    ENSURE_STRING(arg);
    NSString *file = [self dbPath:[TiUtils stringValue:arg]];

    int mode;
    if ([args count] >= 2) {
        arg = [args objectAtIndex:1];
        ENSURE_TYPE(arg, NSNumber);
        mode = [TiUtils intValue:arg];
    } else {
        mode = TCTableDBOpenModeReader |
               TCTableDBOpenModeWriter |
               TCTableDBOpenModeCreate;
    }
    NSLog(@"[INFO] open: %@ mode: %d", file, mode);

    return NUMINT([tdb open:file mode:mode]);
}

- (id)close:(id)args {
    return NUMINT([tdb close]);
}

@end
