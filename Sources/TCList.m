#import "TCInternal.h"
#import "TCList.h"
#import "NSObject+TCUtils.h"

@implementation TCList

@synthesize list;

#pragma mark NSObject

+ (id)list {
    return [[[TCList alloc] init] autorelease];
}

+ (id)listWithNumber:(NSInteger)num {
    return [[[TCList alloc] initWithNumber:num] autorelease];
}

+ (id)listWithList:(TCList *)aList {
    return [[[TCList alloc] initWithList:aList] autorelease];
}

+ (id)listWithInternalList:(TCLIST *)aList {
    return [[[TCList alloc] initWithInternalList:aList] autorelease];
}

- (id)init {
    if ((self = [super init])) {
        list = tclistnew();
    }
    return self;
}

- (id)initWithNumber:(NSInteger)num {
    if ((self = [super init])) {
        list = tclistnew2(num);
    }
    return self;
}

- (id)initWithList:(TCList *)aList {
    if ((self = [super init])) {
        list = tclistdup(aList.list);
    }
    return self;
}

- (id)initWithInternalList:(TCLIST *)aList {
    if ((self = [super init])) {
        list = aList;
    }
    return self;
}

- (void)dealloc {
    if (list) {
        tclistdel(list);
        list = NULL;
    }

    [super dealloc];
}

- (NSString *)description {
    return @"<TCList>";
}

#pragma mark Public Methods

- (NSInteger)count {
    return tclistnum(list);
}

- (id)objectAtIndex:(NSInteger)index {
    return [NSString stringWithUTF8String:tclistval2(list, index)];
}

- (void)addObject:(id)object {
    tclistpush2(list, [(NSString *)object UTF8String]);
}

- (id)popObject {
    return [NSString stringWithUTF8String:tclistpop2(list)];
}

- (void)unshiftObject:(id)object {
    tclistunshift2(list, [(NSString *)object UTF8String]);
}

- (id)shiftObject {
    return [NSString stringWithUTF8String:tclistshift2(list)];
}

- (void)insertObject:(id)object atIndex:(NSInteger)index {
    tclistinsert2(list, index, [(NSString *)object UTF8String]);
}

- (void)removeObjectAtIndex:(NSInteger)index {
    tclistremove2(list, index);
}

- (void)replaceObjectAtIndex:(NSInteger)index withObject:(id)object {
    tclistover2(list, index, [(NSString *)object UTF8String]);
}

- (void)sort {
    tclistsort(list);
}

- (NSInteger)indexOfObject:(id)object {
    return [self linearSearch:object];
}

- (NSInteger)linearSearch:(NSString *)object {
    const char *str = [object UTF8String];
    return tclistlsearch(list, str, strlen(str));
}

- (NSInteger)binarySearch:(NSString *)object {
    const char *str = [object UTF8String];
    return tclistbsearch(list, str, strlen(str));
}

- (void)removeAllObjects {
    tclistclear(list);
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        NSData *data = [decoder decodeObjectForKey:@"list"];
        list = tclistload([data bytes], [data length]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    int size;
    void *bytes = tclistdump(list, &size);
    NSData *data = [NSData dataWithBytes:bytes length:size];
    tcfree(bytes);
    [encoder encodeObject:data forKey:@"list"];
}

@end
