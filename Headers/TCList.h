#import <Foundation/Foundation.h>
#import <TokyoCabinet/TCCoding.h>
#import <TokyoCabinet/tcutil.h>

@interface TCList : NSObject <NSCoding, NSFastEnumeration> {
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
- (NSString *)objectAtIndex:(int)index;
- (void)addObject:(NSString *)object;
- (NSString *)popObject;
- (void)unshiftObject:(NSString *)object;
- (NSString *)shiftObject;
- (void)insertObject:(NSString *)object atIndex:(int)index;
- (void)removeObjectAtIndex:(int)index;
- (void)replaceObjectAtIndex:(int)index withObject:(NSString *)object;
- (void)sort;
- (int)indexOfObject:(NSString *)object;
- (int)linearSearch:(NSString *)object;
- (int)binarySearch:(NSString *)object;
- (void)removeAllObjects;

@end
