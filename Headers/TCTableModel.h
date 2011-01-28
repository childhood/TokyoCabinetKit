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

+ (TCTableDB *)tdb;
+ (void)close;
+ (NSString *)generateKey;

- (void)assignKey;
- (void)save;

@end
