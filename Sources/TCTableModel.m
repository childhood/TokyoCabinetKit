#import <objc/runtime.h>
#import <objc/message.h>
#import "TCInternal.h"
#import "NSObject+TokyoCabinet.h"
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
            [tdb_ setMutex];
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
    return [NSString stringWithFormat:@"lld", [[[self class] tdb] generateUniqueId]];
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
    @synchronized(self) {
        if (!key)
            self.key = [TCTableModel generateKey];
    }
}

- (void)save {
    [self assignKey];
    [[[self class] tdb] setMap:self.map forKey:key];
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
        objc_property_t p;
        char type;
        if (method.length >= 5 && [[method substringToIndex:3] isEqualToString:@"set"]) {
            NSString *prop = [[method substringWithRange:NSMakeRange(3, 1)] lowercaseString];
            p = class_getProperty([self class], [prop UTF8String]);
            type = p ? property_getAttributes(p)[1] : '@';
            signature = [NSMethodSignature signatureWithObjCTypes:
                         [[NSString stringWithFormat:@"v:@%c", type] UTF8String]];
        } else {
            p = class_getProperty([self class], [method UTF8String]);
            type = p ? property_getAttributes(p)[1] : '@';
            signature = [NSMethodSignature signatureWithObjCTypes:
                         [[NSString stringWithFormat:@"%c:@", type] UTF8String]];
        }
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

        objc_property_t p = class_getProperty([self class], [prop UTF8String]);
        char type = p ? property_getAttributes(p)[1] : '@';
        void *value;
        NSString *str;
        if (type == 'c') { // char, BOOL
            char c;
            [invocation getArgument:&c atIndex:2];
            str = [NSString stringWithFormat:@"%hhd", c];
        } else if (type == 'i') { // int
            int i;
            [invocation getArgument:&i atIndex:2];
            str = [NSString stringWithFormat:@"%d", i];
        } else if (type == 's') { // short
            short s;
            [invocation getArgument:&s atIndex:2];
            str = [NSString stringWithFormat:@"%hd", s];
        } else if (type == 'l') { // long
            long l;
            [invocation getArgument:&l atIndex:2];
            str = [NSString stringWithFormat:@"%ld", l];
        } else if (type == 'q') { // long long
            long long ll;
            [invocation getArgument:&ll atIndex:2];
            str = [NSString stringWithFormat:@"%ld", ll];
        } else if (type == 'C') { // unsigned char
            unsigned char uc;
            [invocation getArgument:&uc atIndex:2];
            str = [NSString stringWithFormat:@"%hhu", uc];
        } else if (type == 'I') { // unsigned int
            unsigned int ui;
            [invocation getArgument:&ui atIndex:2];
            str = [NSString stringWithFormat:@"%u", ui];
        } else if (type == 'S') { // unsigned short
            unsigned short us;
            [invocation getArgument:&us atIndex:2];
            str = [NSString stringWithFormat:@"%hu", us];
        } else if (type == 'L') { // unsigned long
            unsigned long ul;
            [invocation getArgument:&ul atIndex:2];
            str = [NSString stringWithFormat:@"%lu", ul];
        } else if (type == 'Q') { // unsigned long long
            unsigned long long ull;
            [invocation getArgument:&ull atIndex:2];
            str = [NSString stringWithFormat:@"%lu", ull];
        } else if (type == 'f') { // float
            float f;
            [invocation getArgument:&f atIndex:2];
            str = [NSString stringWithFormat:@"%f", f];
        } else if (type == 'd') { // double
            double d;
            [invocation getArgument:&d atIndex:2];
            str = [NSString stringWithFormat:@"%lf", d];
        } else if (type == '@') {
            id obj;
            [invocation getArgument:&obj atIndex:2];
            str = [obj encodeForTC];
        } else {
            str = value;
        }
        [inv setArgument:&str atIndex:2];
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

        objc_property_t p = class_getProperty([self class], [prop UTF8String]);
        char type = p ? property_getAttributes(p)[1] : '@';

        if (type == 'c') { // char, BOOL
            char c = [ret integerValue];
            [invocation setReturnValue:&c];
        } else if (type == 'i') { // int
            int i = [ret integerValue];
            [invocation setReturnValue:&i];
        } else if (type == 's') { // short
            short s = [ret integerValue];
            [invocation setReturnValue:&s];
        } else if (type == 'l') { // long
            long l = strtol(ret ? [ret UTF8String] : "0", NULL, 0);
            [invocation setReturnValue:&l];
        } else if (type == 'q') { // long long
            long long ll = strtoll(ret ? [ret UTF8String] : "0", NULL, 0);
            [invocation setReturnValue:&ll];
        } else if (type == 'C') { // unsigned char
            unsigned char uc = [ret integerValue];
            [invocation setReturnValue:&uc];
        } else if (type == 'I') { // unsigned int
            unsigned int ui = [ret integerValue];
            [invocation setReturnValue:&ui];
        } else if (type == 'S') { // unsigned short
            unsigned short us = [ret integerValue];
            [invocation setReturnValue:&us];
        } else if (type == 'L') { // unsigned long
            unsigned long ul = strtoul(ret ? [ret UTF8String] : "0", NULL, 0);
            [invocation setReturnValue:&ul];
        } else if (type == 'Q') { // unsigned long long
            unsigned long long ull = strtoull(ret ? [ret UTF8String] : "0", NULL, 0);
            [invocation setReturnValue:&ull];
        } else if (type == 'f') { // float
            float f = [ret floatValue];
            [invocation setReturnValue:&f];
        } else if (type == 'd') { // double
            double d = [ret doubleValue];
            [invocation setReturnValue:&d];
        } else if (type == '@') {
            NSArray *params = [[NSString stringWithUTF8String:property_getAttributes(p)]
                               componentsSeparatedByString: @","];
            NSString *first = [params objectAtIndex:0];
            NSString *klass = [first substringWithRange:NSMakeRange(3, first.length - 4)];
            id obj = [objc_getClass([klass UTF8String]) decodeFromTC:ret];
            [invocation setReturnValue:&obj];
        } else {
            [invocation setReturnValue:&ret];
        }
    }
}

//- (BOOL)respondsToSelector:(SEL)selector {
//    return YES;
//}

@end
