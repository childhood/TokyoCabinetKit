#import "TCInternal.h"
#import "TCList.h"
#import "NSObject+TCUtils.h"

@implementation TCList

@synthesize list;

#pragma mark NSObject

+ (id)list {
    return [[[TCList alloc] init] autorelease];
}

+ (id)listWithNumber:(int)num {
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

- (id)initWithNumber:(int)num {
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

- (int)count {
    return tclistnum(list);
}

- (NSString *)objectAtIndex:(int)index {
    return [NSString stringWithUTF8String:tclistval2(list, index)];
}

- (void)addObject:(NSString *)object {
    tclistpush2(list, [object UTF8String]);
}

- (NSString *)popObject {
    return [NSString stringWithUTF8String:tclistpop2(list)];
}

- (void)unshiftObject:(NSString *)object {
    tclistunshift2(list, [object UTF8String]);
}

- (NSString *)shiftObject {
    return [NSString stringWithUTF8String:tclistshift2(list)];
}

- (void)insertObject:(NSString *)object atIndex:(int)index {
    tclistinsert2(list, index, [object UTF8String]);
}

- (void)removeObjectAtIndex:(int)index {
    tclistremove2(list, index);
}

- (void)replaceObjectAtIndex:(int)index withObject:(NSString *)object {
    tclistover2(list, index, [object UTF8String]);
}

- (void)sort {
    tclistsort(list);
}

- (int)indexOfObject:(NSString *)object {
    return [self linearSearch:object];
}

- (int)linearSearch:(NSString *)object {
    const char *str = [object UTF8String];
    return tclistlsearch(list, str, strlen(str));
}

- (int)binarySearch:(NSString *)object {
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

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len {
    if (state->state >= self.count)
        return 0;

    int count = 0;
    while (state->state < self.count && count < len) {
        stackbuf[count] = [self objectAtIndex:state->state];
        count += 1;
        state->state += 1;
    }

    state->itemsPtr = stackbuf;
    state->mutationsPtr = (unsigned long *)self;

    return count;
}

@end
