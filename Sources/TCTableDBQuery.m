#import "TCInternal.h"
#import "TCTableDBQuery.h"
#import "TCTableDB.h"
#import "TCList.h"

@implementation TCTableDBQuery

@synthesize tdb;
@synthesize query;

#pragma mark NSObject

+ (id)queryWithTableDB:(TCTableDB *)aTdb {
    return [[[TCTableDBQuery alloc] initWithTableDB:aTdb] autorelease];
}

- (id)initWithTableDB:(TCTableDB *)aTdb {
    if ((self = [super init])) {
        self.tdb = aTdb;
        query = tctdbqrynew(tdb.tdb);
    }
    return self;
}

- (void)dealloc {
    tctdbqrydel(query);
    query = NULL;

    [tdb release];

    [super dealloc];
}

#pragma mark Public Methods

- (void)addConditionForColumn:(NSString *)name
                         type:(TCTableDBQueryConditionType)type
                   expression:(NSString *)expression {
    tctdbqryaddcond(query, [name UTF8String], type, [expression UTF8String]);
}

- (void)addConditionForColumn:(NSString *)name
               stringEqualsTo:(NSString *)expression {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionStringEqual
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
               stringIncludes:(NSString *)expression {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionStringInclude
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
              stringBeginWith:(NSString *)expression {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionStringBegin
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
                stringEndWith:(NSString *)expression {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionStringEnd
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
            stringIncludesAll:(NSString *)str, ... {
    NSMutableString *expression = [NSMutableString stringWithString:str];
    NSString *arg;

    va_list args;
    va_start(args, str);
    while ((arg = va_arg(args, NSString *))) {
        [expression appendFormat:@" %@", arg];
    }
    va_end(args);

    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionStringAnd
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
          stringIncludesOneOf:(NSString *)str, ... {
    NSMutableString *expression = [NSMutableString stringWithString:str];
    NSString *arg;

    va_list args;
    va_start(args, str);
    while ((arg = va_arg(args, NSString *))) {
        [expression appendFormat:@" %@", arg];
    }
    va_end(args);

    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionStringOr
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
            stringEqualsOneOf:(NSString *)str, ... {
    NSMutableString *expression = [NSMutableString stringWithString:str];
    NSString *arg;

    va_list args;
    va_start(args, str);
    while ((arg = va_arg(args, NSString *))) {
        [expression appendFormat:@" %@", arg];
    }
    va_end(args);

    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionStringOr
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
            stringMatcesRegex:(NSString *)expression {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionStringRegex
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
               numberEqualsTo:(NSNumber *)number {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionNumberEqual
                     expression:[number stringValue]];
}

- (void)addConditionForColumn:(NSString *)name
            numberGreaterThan:(NSNumber *)number {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionNumberGreaterThan
                     expression:[number stringValue]];
}

- (void)addConditionForColumn:(NSString *)name
     numberGreaterThanOrEqual:(NSNumber *)number {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionNumberGreaterEqual
                     expression:[number stringValue]];
}

- (void)addConditionForColumn:(NSString *)name
               numberLessThan:(NSNumber *)number {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionNumberLessThan
                     expression:[number stringValue]];
}

- (void)addConditionForColumn:(NSString *)name
        numberLessThanOrEqual:(NSNumber *)number {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionNumberLessEqual
                     expression:[number stringValue]];
}

- (void)addConditionForColumn:(NSString *)name
                numberBetween:(NSNumber *)num1
                          and:(NSNumber *)num2 {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionNumberLessEqual
                     expression:[NSString stringWithFormat:@"%@ %@",
                                 [num1 stringValue], [num2 stringValue]]];
}

- (void)addConditionForColumn:(NSString *)name
            numberEqualsOneOf:(NSNumber *)num, ... {
    NSMutableString *expression = [NSMutableString stringWithString:[num stringValue]];
    NSNumber *arg;

    va_list args;
    va_start(args, num);
    while ((arg = va_arg(args, NSNumber *))) {
        [expression appendFormat:@" %@", [arg stringValue]];
    }
    va_end(args);

    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionNumberOrEqual
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
               fullTextPhrase:(NSString *)expression {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionFullTextPhrase
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
                  fullTextAnd:(NSString *)str, ... {
    NSMutableString *expression = [NSMutableString stringWithString:str];
    NSString *arg;

    va_list args;
    va_start(args, str);
    while ((arg = va_arg(args, NSString *))) {
        [expression appendFormat:@" %@", arg];
    }
    va_end(args);

    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionFullTextAnd
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
                   fullTextOr:(NSString *)str, ... {
    NSMutableString *expression = [NSMutableString stringWithString:str];
    NSString *arg;

    va_list args;
    va_start(args, str);
    while ((arg = va_arg(args, NSString *))) {
        [expression appendFormat:@" %@", arg];
    }
    va_end(args);

    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionFullTextOr
                     expression:expression];
}

- (void)addConditionForColumn:(NSString *)name
                   fullTextEx:(NSString *)expression {
    [self addConditionForColumn:name
                           type:TCTableDBQueryConditionFullTextEx
                     expression:expression];
}

- (void)setOrder:(TCTableDBQueryOrder)order forColumn:(NSString *)name {
    tctdbqrysetorder(query, [name UTF8String], order);
}

- (void)setLimit:(int)limit skip:(int)skip {
    tctdbqrysetlimit(query, limit, skip);
}

- (TCList *)searchKeys {
    return [TCList listWithInternalList:tctdbqrysearch(query)];
}

- (NSArray *)searchMaps {
    TCList *keys = [TCList listWithInternalList:tctdbqrysearch(query)];
    NSMutableArray *maps = [NSMutableArray array];
    for (int i = 0; i < keys.count; i++) {
        [maps addObject:[tdb mapForKey:[keys objectAtIndex:i]]];
    }
    return maps;
}

- (BOOL)remove {
    return tctdbqrysearchout(query);
}

- (NSString *)hint {
    return [NSString stringWithUTF8String:tctdbqryhint(query)];
}

@end
