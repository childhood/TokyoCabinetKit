#import <objc/runtime.h>
#import <objc/message.h>
#import "TCInternal.h"
#import "TCTableModel.h"

static TCTableDB *tdb_ = nil;

@implementation TCTableModel

@synthesize key;

#pragma mark Class Methods

+ (TCTableDB *)tdb {
    @synchronized(self) {
        if (!tdb_) {
            const char *clsName = class_getName([self class]);
            NSArray *paths = NSSearchPathForDirectoriesInDomains(
                NSDocumentDirectory, NSUserDomainMask, YES
            );
            NSString *path = [NSString stringWithFormat:@"%@/%s.tct",
                              [paths objectAtIndex:0], clsName];
            //NSLog(@"path: %@", path);
            tdb_ = [[TCTableDB alloc] initWithFile:path
                                             mode:TCTableDBOpenModeWriter |
                                                  TCTableDBOpenModeCreate];
        }
    }
    return tdb_;
}

+ (void)close {
    @synchronized(self) {
        if (tdb_) {
            [tdb_ release];
            tdb_ = nil;
        }
    }
}

+ (NSString *)generateKey {
    TCTableDB *db = [TCTableModel tdb];
    NSString *str;
    @synchronized(self) {
        str = [NSString stringWithFormat:@"%lld", [db generateUniqueId]];
    }
    return str;
}

#pragma mark NSObject

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)dealloc {
    [key release];
    [map release];

    [super dealloc];
}

#pragma mark Accessors

- (TCMap *)map {
    if (map) return map;

    TCTableDB *db = [TCTableModel tdb];
    if (key)
        map = [[db mapForKey:key] retain];
    else
        map = [[TCMap alloc] init];

    return map;
}

- (void)setMap:(TCMap *)aMap {
    if (map == aMap) return;
    [map release];
    map = [aMap retain];
}

#pragma mark Methods

- (void)assignKey {
    if (!key)
        self.key = [TCTableModel generateKey];
        //self.key = @"1";
}

- (void)save {
    @synchronized(self) {
        TCTableDB *db = [TCTableModel tdb];
        [self assignKey];

        [db setMap:self.map forKey:key];
    }
}

#pragma mark NSKeyValueCoding

- (void)setValue:(id)value forKey:(NSString *)aKey {
    [self.map setValue:value forKey:aKey];
}

- (id)valueForKey:(NSString *)aKey {
    if ([[aKey substringToIndex:1] isEqualToString:@"@"])
        return [super valueForKey:[aKey substringFromIndex:1]];
    else
        return [self.map valueForKey:aKey];
}

#pragma mark Dynamic Properties

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSString *method = NSStringFromSelector(selector);
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        if (method.length >= 5 && [[method substringToIndex:3] isEqualToString:@"set"])
            signature = [NSMethodSignature signatureWithObjCTypes:"v:@@"];
        else
            signature = [NSMethodSignature signatureWithObjCTypes:"@:@"];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *method = NSStringFromSelector([invocation selector]);

    NSMethodSignature *sig;
    NSString *prop;
    NSInvocation *inv;

    if (method.length >= 5 && [[method substringToIndex:3] isEqualToString:@"set"]) {
        sig = [[self class] instanceMethodSignatureForSelector:@selector(setValue:forKey:)];
        if (method.length == 5)
            prop = [[method substringWithRange:NSMakeRange(3, 1)] lowercaseString];
        else
            prop = [NSString stringWithFormat:@"%@%@",
                    [[method substringWithRange:NSMakeRange(3, 1)] lowercaseString],
                    [method substringWithRange:NSMakeRange(4, method.length - 5)]];

        inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:@selector(setValue:forKey:)];
        id value;
        [invocation getArgument:&value atIndex:2];
        [inv setArgument:&value atIndex:2];
        [inv setArgument:&prop atIndex:3];
        [inv invoke];
    } else {
        sig = [[self class] instanceMethodSignatureForSelector:@selector(valueForKey:)];
        prop = method;
        inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:@selector(valueForKey:)];
        [inv setArgument:&prop atIndex:2];
        [inv invoke];

        NSString *ret;
        [inv getReturnValue:&ret];
        [invocation setReturnValue:&ret];
    }
}

//- (BOOL)respondsToSelector:(SEL)selector {
//    return YES;
//}

@end
