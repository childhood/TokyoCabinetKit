#import <objc/runtime.h>
#import <objc/message.h>
#import "TCInternal.h"
#import "NSString+TCCoding.h"
#import "TCTableModel.h"

static TCTableDB *tdb_ = nil;

@implementation NSString (TCCoding)

+ (id)decodeFromTC:(NSString *)str {
    return str;
}

- (NSString *)encodeForTC {
    return self;
}

@end

@implementation TCTableModel

@synthesize key;
@synthesize modified;

#pragma mark Local Methods

+ (NSString *)propertyNameFromMethodName:(NSString *)method prefix:(NSString *)prefix {
    NSString *prop = method;
    if (method.length >= prefix.length + 2 &&
        [[method substringToIndex:prefix.length] isEqualToString:prefix]) {
        if (method.length == prefix.length + 2)
            prop = [[method substringWithRange:NSMakeRange(prefix.length, 1)] lowercaseString];
        else
            prop = [NSString stringWithFormat:@"%@%@",
                    [[method substringWithRange:NSMakeRange(prefix.length, 1)] lowercaseString],
                    [method substringWithRange:NSMakeRange(prefix.length + 1, method.length - prefix.length - 2)]];
    }
    return prop;
}

+ (void)setInvocationReturn:(NSInvocation *)invocation
                   property:(NSString *)property
                      value:(NSString *)value {
    objc_property_t p = class_getProperty([self class], [property UTF8String]);
    char type = p ? property_getAttributes(p)[1] : '@';

    if (type == 'c') { // char, BOOL
        char c = [value integerValue];
        [invocation setReturnValue:&c];
    } else if (type == 'i') { // int
        int i = [value integerValue];
        [invocation setReturnValue:&i];
    } else if (type == 's') { // short
        short s = [value integerValue];
        [invocation setReturnValue:&s];
    } else if (type == 'l') { // long
        long l = strtol(value ? [value UTF8String] : "0", NULL, 0);
        [invocation setReturnValue:&l];
    } else if (type == 'q') { // long long
        long long ll = strtoll(value ? [value UTF8String] : "0", NULL, 0);
        [invocation setReturnValue:&ll];
    } else if (type == 'C') { // unsigned char
        unsigned char uc = [value integerValue];
        [invocation setReturnValue:&uc];
    } else if (type == 'I') { // unsigned int
        unsigned int ui = [value integerValue];
        [invocation setReturnValue:&ui];
    } else if (type == 'S') { // unsigned short
        unsigned short us = [value integerValue];
        [invocation setReturnValue:&us];
    } else if (type == 'L') { // unsigned long
        unsigned long ul = strtoul(value ? [value UTF8String] : "0", NULL, 0);
        [invocation setReturnValue:&ul];
    } else if (type == 'Q') { // unsigned long long
        unsigned long long ull = strtoull(value ? [value UTF8String] : "0", NULL, 0);
        [invocation setReturnValue:&ull];
    } else if (type == 'f') { // float
        float f = [value floatValue];
        [invocation setReturnValue:&f];
    } else if (type == 'd') { // double
        double d = [value doubleValue];
        [invocation setReturnValue:&d];
    } else if (type == '@') {
        NSArray *params = [[NSString stringWithUTF8String:property_getAttributes(p)]
                           componentsSeparatedByString: @","];
        NSString *first = [params objectAtIndex:0];
        NSString *klass = [first substringWithRange:NSMakeRange(3, first.length - 4)];
        id obj = [objc_getClass([klass UTF8String]) decodeFromTC:value];
        [invocation setReturnValue:&obj];
    } else {
        [invocation setReturnValue:&value];
    }
}

+ (NSString *)stringFromInvocation:(NSInvocation *)invocation
                          property:(NSString *)property
                             index:(NSInteger)index {
    objc_property_t p = class_getProperty([self class], [property UTF8String]);
    char type = p ? property_getAttributes(p)[1] : '@';
    NSString *str;

    if (type == 'c') { // char, BOOL
        char c;
        [invocation getArgument:&c atIndex:index];
        str = [NSString stringWithFormat:@"%hhd", c];
    } else if (type == 'i') { // int
        int i;
        [invocation getArgument:&i atIndex:index];
        str = [NSString stringWithFormat:@"%d", i];
    } else if (type == 's') { // short
        short s;
        [invocation getArgument:&s atIndex:index];
        str = [NSString stringWithFormat:@"%hd", s];
    } else if (type == 'l') { // long
        long l;
        [invocation getArgument:&l atIndex:index];
        str = [NSString stringWithFormat:@"%ld", l];
    } else if (type == 'q') { // long long
        long long ll;
        [invocation getArgument:&ll atIndex:index];
        str = [NSString stringWithFormat:@"%ld", ll];
    } else if (type == 'C') { // unsigned char
        unsigned char uc;
        [invocation getArgument:&uc atIndex:index];
        str = [NSString stringWithFormat:@"%hhu", uc];
    } else if (type == 'I') { // unsigned int
        unsigned int ui;
        [invocation getArgument:&ui atIndex:index];
        str = [NSString stringWithFormat:@"%u", ui];
    } else if (type == 'S') { // unsigned short
        unsigned short us;
        [invocation getArgument:&us atIndex:index];
        str = [NSString stringWithFormat:@"%hu", us];
    } else if (type == 'L') { // unsigned long
        unsigned long ul;
        [invocation getArgument:&ul atIndex:index];
        str = [NSString stringWithFormat:@"%lu", ul];
    } else if (type == 'Q') { // unsigned long long
        unsigned long long ull;
        [invocation getArgument:&ull atIndex:index];
        str = [NSString stringWithFormat:@"%lu", ull];
    } else if (type == 'f') { // float
        float f;
        [invocation getArgument:&f atIndex:index];
        str = [NSString stringWithFormat:@"%f", f];
    } else if (type == 'd') { // double
        double d;
        [invocation getArgument:&d atIndex:index];
        str = [NSString stringWithFormat:@"%lf", d];
    } else if (type == '@') {
        id obj;
        [invocation getArgument:&obj atIndex:index];
        str = [obj encodeForTC];
    } else {
        str = nil;
    }

    return str;
}

#pragma mark Class Methods

+ (id)model {
    return [[[[self class] alloc] init] autorelease];
}

+ (id)modelWithKey:(NSString *)aKey {
    return [[[[self class] alloc] initWithKey:aKey] autorelease];
}

+ (TCTableDB *)tdb {
    @synchronized(self) {
        if (!tdb_) {
            const char *clsName = class_getName([self class]);
            NSArray *paths = NSSearchPathForDirectoriesInDomains(
                NSDocumentDirectory, NSUserDomainMask, YES
            );
            NSString *path = [NSString stringWithFormat:@"%@/%s.tct",
                              [paths objectAtIndex:0], clsName];
            tdb_ = [[TCTableDB alloc] initWithFile:path
                                             mode:TCTableDBOpenModeReader |
                                                  TCTableDBOpenModeWriter |
                                                  TCTableDBOpenModeCreate
                   ];
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
    return [NSString stringWithFormat:@"%lld", [[[self class] tdb] generateUniqueId]];
}

+ (id)findByKey:(NSString *)aKey {
    return [[[[self class] alloc] initWithKey:aKey] autorelease];
}

+ (NSArray *)findAll:(id)val by:(NSString *)col {
    TCTableDBQuery *query = [TCTableDBQuery queryWithTableDB:[[self class] tdb]];
    [query addConditionForColumn:col stringEqualsTo:[val encodeForTC]];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in [query searchKeys]) {
        [array addObject:[[self class] modelWithKey:key]];
    }
    return array;
}

+ (id)find:(id)val by:(NSString *)col {
    TCTableDBQuery *query = [TCTableDBQuery queryWithTableDB:[[self class] tdb]];
    [query addConditionForColumn:col stringEqualsTo:[val encodeForTC]];
    TCList *list = [query searchKeys];
    return list.count > 0 ? [[self class] findByKey:[list objectAtIndex:0]] : 0;
}

+ (id)findString:(NSString *)val by:(NSString *)col {
    return [[self class] find:val by:col];
}

+ (id)findBool:(BOOL)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%hhd", val] by:col];
}

+ (id)findChar:(char)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%hhd", val] by:col];
}

+ (id)findDouble:(double)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%lf", val] by:col];
}

+ (id)findFloat:(float)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%f", val] by:col];
}

+ (id)findInt:(int)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%d", val] by:col];
}

+ (id)findInteger:(NSInteger)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%d", val] by:col];
}

+ (id)findLong:(long)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%ld", val] by:col];
}

+ (id)findLongLong:(long long)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%ld", val] by:col];
}

+ (id)findShort:(short)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%hd", val] by:col];
}

+ (id)findUnsignedChar:(unsigned char)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%hhu", val] by:col];
}

+ (id)findUnsignedInt:(unsigned int)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%u", val] by:col];
}

+ (id)findUnsignedInteger:(NSUInteger)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%u", val] by:col];
}

+ (id)findUnsignedLong:(unsigned long)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%lu", val] by:col];
}

+ (id)findUnsignedLongLong:(unsigned long long)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%lu", val] by:col];
}

+ (id)findUnsignedShort:(unsigned short)val by:(NSString *)col {
    return [[self class] find:[NSString stringWithFormat:@"%hu", val] by:col];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSString *method = NSStringFromSelector(selector);
    objc_property_t p;
    char type;
    NSMethodSignature *sig = nil;
    if (method.length >= 8 && [[method substringToIndex:6] isEqualToString:@"findBy"]) {
        NSString *prop = [[self class] propertyNameFromMethodName:method prefix:@"findBy"];
        p = class_getProperty([self class], [prop UTF8String]);
        type = p ? property_getAttributes(p)[1] : '@';
        sig = [NSMethodSignature signatureWithObjCTypes:
               [[NSString stringWithFormat:@"@:@%c", type] UTF8String]];
    }
    return sig;
}

+ (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *method = NSStringFromSelector([invocation selector]);
    if (method.length >= 8 && [[method substringToIndex:6] isEqualToString:@"findBy"]) {
        NSString *prop = [[self class] propertyNameFromMethodName:method prefix:@"findBy"];
        NSString *str = [[self class] stringFromInvocation:invocation property:prop index:2];
        id obj = [[self class] find:str by:prop];
        [invocation setReturnValue:&obj];
    }
}

#pragma mark Proxy to TCTableDB

+ (int)ecode {
    return [[[self class] tdb] ecode];
}

+ (NSString *)errorMessage {
    return [[[self class] tdb] errorMessage];
}

+ (NSString *)errorMessage:(int)ecode {
    return [[[self class] tdb] errorMessage:ecode];
}

+ (BOOL)tuneBnum:(int64_t)bnum apow:(int8_t)apow fpow:(int8_t)fpow opts:(uint8_t)opts {
    return [[[self class] tdb] tuneBnum:bnum apow:apow fpow:fpow opts:opts];
}

+ (BOOL)setCacheRcnum:(int32_t)rcnum lcnum:(int32_t)lcnum ncnum:(int32_t)ncnum {
    return [[[self class] tdb] setCacheRcnum:rcnum lcnum:lcnum ncnum:ncnum];
}

+ (BOOL)setXmsiz:(int64_t)xmsiz {
    return [[[self class] tdb] setXmsiz:xmsiz];
}

+ (BOOL)setDfunit:(int32_t)dfunit {
    return [[[self class] tdb] setDfunit:dfunit];
}

+ (int)mapSizeForKey:(id)key {
    return [[[self class] tdb] mapSizeForKey:key];
}

+ (TCList *)forwardMatchingKeys:(id)key max:(int)max {
    return [[[self class] tdb] forwardMatchingKeys:key max:max];
}

+ (void)sync {
    [[[self class] tdb] sync];
}

+ (BOOL)optimizeBnum:(int64_t)bnum apow:(int8_t)apow fpow:(int8_t)fpow opts:(uint8_t)opts {
    return [[[self class] tdb] optimizeBnum:bnum apow:apow fpow:fpow opts:opts];
}

+ (void)removeAllObjects {
    [[[self class] tdb] removeAllObjects];
}

+ (BOOL)beginTransaction {
    return [[[self class] tdb] beginTransaction];
}

+ (BOOL)commitTransaction {
    return [[[self class] tdb] commitTransaction];
}

+ (BOOL)abortTransaction {
    return [[[self class] tdb] abortTransaction];
}

+ (NSString *)path {
    return [[[self class] tdb] path];
}

+ (uint64_t)count {
    return [[[self class] tdb] count];
}

+ (uint64_t)size {
    return [[[self class] tdb] size];
}

+ (BOOL)setIndex:(TCTableDBIndexType)type forColumn:(NSString *)name {
    return [[[self class] tdb] setIndex:type forColumn:name];
}

+ (BOOL)setIndex:(TCTableDBIndexType)type forColumn:(NSString *)name keep:(BOOL)keep {
    return [[[self class] tdb] setIndex:type forColumn:name keep:keep];
}

+ (BOOL)removeIndex:(TCTableDBIndexType)type forColumn:(NSString *)name {
    return [[[self class] tdb] removeIndex:type forColumn:name];
}

+ (BOOL)optimizeIndexForColumn:(NSString *)name {
    return [[[self class] tdb] optimizeIndexForColumn:name];
}

+ (int64_t)generateUniqueId {
    return [[[self class] tdb] generateUniqueId];
}

#pragma mark Search

+ (NSArray *)search:(TCTableDBQuery *)query {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in [query searchKeys]) {
        [array addObject:[[self class] modelWithKey:key]];
    }
    return array;
}

+ (NSArray *)metaSearch:(NSArray *)queries type:(int)type {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in [[[self class] tdb] metaSearch:queries type:type]) {
        [array addObject:[[self class] modelWithKey:key]];
    }
    return array;
}

#pragma mark NSObject

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (id)initWithKey:(NSString *)aKey {
    if ((self = [super init])) {
        self.key = aKey;
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

    TCTableDB *db = [[self class] tdb];
    if (key)
        map = [[db mapForKey:key] retain];
    if (!map)
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
            self.key = [[self class] generateKey];
    }
}

- (void)save {
    @synchronized(self) {
        if (modified) {
            [self assignKey];
            [[[self class] tdb] setMap:self.map forKey:key];
            modified = NO;
        }
    }
}

#pragma mark NSKeyValueCoding

- (void)setValue:(id)value forKey:(NSString *)aKey {
    [self.map setValue:value forKey:aKey];
    modified = YES;
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
    NSMethodSignature *sig = nil;
    objc_property_t p;
    char type;
    if (method.length >= 5 && [[method substringToIndex:3] isEqualToString:@"set"]) {
        NSString *prop = [[self class] propertyNameFromMethodName:method prefix:@"set"];
        p = class_getProperty([self class], [prop UTF8String]);
        type = p ? property_getAttributes(p)[1] : '@';
        sig = [NSMethodSignature signatureWithObjCTypes:
               [[NSString stringWithFormat:@"v:@%c", type] UTF8String]];
    } else {
        p = class_getProperty([self class], [method UTF8String]);
        type = p ? property_getAttributes(p)[1] : '@';
        sig = [NSMethodSignature signatureWithObjCTypes:
               [[NSString stringWithFormat:@"%c:@", type] UTF8String]];
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *method = NSStringFromSelector([invocation selector]);

    NSMethodSignature *sig;
    NSString *prop;
    NSInvocation *inv;

    if (method.length >= 5 && [[method substringToIndex:3] isEqualToString:@"set"]) {
        sig = [[self class] instanceMethodSignatureForSelector:@selector(setValue:forKey:)];
        prop = [[self class] propertyNameFromMethodName:method prefix:@"set"];
        inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:@selector(setValue:forKey:)];
        NSString *str = [[self class] stringFromInvocation:invocation property:prop index:2];
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
        [[self class] setInvocationReturn:invocation property:prop value:ret];
    }
}

//- (BOOL)respondsToSelector:(SEL)selector {
//    return YES;
//}

@end
