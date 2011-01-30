#import <Foundation/Foundation.h>
#import <Foundation/NSKeyValueCoding.h>
#import <TokyoCabinet/TCTableDB.h>

@interface TCTableModel : NSObject {
@private
    NSString *key;
    TCMap *map;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) TCMap *map;

+ (id)model;
+ (TCTableDB *)tdb;
+ (void)sync;
+ (void)close;
+ (NSString *)generateKey;
+ (id)findByKey:(NSString *)aKey;

- (id)init;
- (id)initWithFindingByKey:(NSString *)aKey;
- (void)assignKey;
- (void)save;

@end
