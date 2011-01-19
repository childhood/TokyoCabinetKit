#import <Foundation/Foundation.h>
#import <TokyoCabinet/tcutil.h>

@interface TCList : NSObject <NSCoding> {
@private
    TCLIST *list;
}

@property (nonatomic, readonly) TCLIST *list;
@property (nonatomic, readonly) NSInteger count;

+ (id)list;
+ (id)listWithNumber:(NSInteger)num;
+ (id)listWithList:(TCList *)aList;
+ (id)listWithInternalList:(TCLIST *)aList;

- (id)initWithNumber:(NSInteger)num;
- (id)initWithList:(TCList *)aList;
- (id)initWithInternalList:(TCLIST *)aList;

- (NSInteger)count;
- (id)objectAtIndex:(NSInteger)index;
- (void)addObject:(id)object;
- (id)popObject;
- (void)unshiftObject:(id)object;
- (id)shiftObject;
- (void)insertObject:(id)object atIndex:(NSInteger)index;
- (void)removeObjectAtIndex:(NSInteger)index;
- (void)replaceObjectAtIndex:(NSInteger)index withObject:(id)object;
- (void)sort;
- (NSInteger)indexOfObject:(id)object;
- (NSInteger)linearSearch:(NSString *)object;
- (NSInteger)binarySearch:(NSString *)object;
- (void)removeAllObjects;

@end
