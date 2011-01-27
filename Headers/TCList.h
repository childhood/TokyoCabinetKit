#import <Foundation/Foundation.h>
#import <TokyoCabinet/tcutil.h>

@interface TCList : NSObject <NSCoding> {
@private
    TCLIST *list;
}

@property (nonatomic, readonly) TCLIST *list;
@property (nonatomic, readonly) int count;

+ (id)list;
+ (id)listWithNumber:(int)num;
+ (id)listWithList:(TCList *)aList;
+ (id)listWithInternalList:(TCLIST *)aList;

- (id)initWithNumber:(int)num;
- (id)initWithList:(TCList *)aList;
- (id)initWithInternalList:(TCLIST *)aList;

- (int)count;
- (id)objectAtIndex:(int)index;
- (void)addObject:(id)object;
- (id)popObject;
- (void)unshiftObject:(id)object;
- (id)shiftObject;
- (void)insertObject:(id)object atIndex:(int)index;
- (void)removeObjectAtIndex:(int)index;
- (void)replaceObjectAtIndex:(int)index withObject:(id)object;
- (void)sort;
- (int)indexOfObject:(id)object;
- (int)linearSearch:(NSString *)object;
- (int)binarySearch:(NSString *)object;
- (void)removeAllObjects;

@end
