#import <Foundation/Foundation.h>
#import <TokyoCabinet/tctdb.h>

typedef enum {
    TCTableDBQueryConditionStringEqual        = TDBQCSTREQ,
    TCTableDBQueryConditionStringInclude      = TDBQCSTRINC,
    TCTableDBQueryConditionStringBegin        = TDBQCSTRBW,
    TCTableDBQueryConditionStringEnd          = TDBQCSTREW,
    TCTableDBQueryConditionStringAnd          = TDBQCSTRAND,
    TCTableDBQueryConditionStringOr           = TDBQCSTROR,
    TCTableDBQueryConditionStringOrEqual      = TDBQCSTROREQ,
    TCTableDBQueryConditionStringRegex        = TDBQCSTRRX,
    TCTableDBQueryConditionNumberEqual        = TDBQCNUMEQ,
    TCTableDBQueryConditionNumberGreaterThan  = TDBQCNUMGT,
    TCTableDBQueryConditionNumberGreaterEqual = TDBQCNUMGE,
    TCTableDBQueryConditionNumberLessThan     = TDBQCNUMLT,
    TCTableDBQueryConditionNumberLessEqual    = TDBQCNUMLE,
    TCTableDBQueryConditionNumberBetween      = TDBQCNUMBT,
    TCTableDBQueryConditionNumberOrEqual      = TDBQCNUMOREQ,
    TCTableDBQueryConditionFullTextPhrase     = TDBQCFTSPH,
    TCTableDBQueryConditionFullTextAnd        = TDBQCFTSAND,
    TCTableDBQueryConditionFullTextOr         = TDBQCFTSOR,
    TCTableDBQueryConditionFullTextEx         = TDBQCFTSEX
} TCTableDBQueryConditionType;

typedef enum {
    TCTableDBQueryOrderStringAsc  = TDBQOSTRASC,
    TCTableDBQueryOrderStringDesc = TDBQOSTRDESC,
    TCTableDBQueryOrderNumberAsc  = TDBQONUMASC,
    TCTableDBQueryOrderNumberDesc = TDBQONUMDESC
} TCTableDBQueryOrder;

@class TCTableDB;
@class TCList;

@interface TCTableDBQuery : NSObject {
@private
    TCTableDB *tdb;
    TDBQRY *query;
}

@property (nonatomic, retain) TCTableDB *tdb;
@property (nonatomic, readonly) TDBQRY *query;
@property (nonatomic, readonly) NSString *hint;

+ (id)queryWithTableDB:(TCTableDB *)aTdb;

- (id)initWithTableDB:(TCTableDB *)aTdb;

- (void)addConditionForColumn:(NSString *)name
                         type:(TCTableDBQueryConditionType)type
                   expression:(NSString *)expression;

- (void)addConditionForColumn:(NSString *)name
               stringEqualsTo:(NSString *)expression;

- (void)addConditionForColumn:(NSString *)name
               stringIncludes:(NSString *)expression;

- (void)addConditionForColumn:(NSString *)name
              stringBeginWith:(NSString *)expression;

- (void)addConditionForColumn:(NSString *)name
                stringEndWith:(NSString *)expression;

- (void)addConditionForColumn:(NSString *)name
            stringIncludesAll:(NSString *)str, ...;

- (void)addConditionForColumn:(NSString *)name
          stringIncludesOneOf:(NSString *)str, ...;

- (void)addConditionForColumn:(NSString *)name
            stringEqualsOneOf:(NSString *)str, ...;

- (void)addConditionForColumn:(NSString *)name
            stringMatcesRegex:(NSString *)expression;

- (void)addConditionForColumn:(NSString *)name
               numberEqualsTo:(NSNumber *)number;

- (void)addConditionForColumn:(NSString *)name
            numberGreaterThan:(NSNumber *)number;

- (void)addConditionForColumn:(NSString *)name
     numberGreaterThanOrEqual:(NSNumber *)number;

- (void)addConditionForColumn:(NSString *)name
               numberLessThan:(NSNumber *)number;

- (void)addConditionForColumn:(NSString *)name
        numberLessThanOrEqual:(NSNumber *)number;

- (void)addConditionForColumn:(NSString *)name
                numberBetween:(NSNumber *)num1
                          and:(NSNumber *)num2;

- (void)addConditionForColumn:(NSString *)name
            numberEqualsOneOf:(NSNumber *)num, ...;

- (void)addConditionForColumn:(NSString *)name
               fullTextPhrase:(NSString *)expression;

- (void)addConditionForColumn:(NSString *)name
                  fullTextAnd:(NSString *)str, ...;

- (void)addConditionForColumn:(NSString *)name
                   fullTextOr:(NSString *)str, ...;

- (void)addConditionForColumn:(NSString *)name
                   fullTextEx:(NSString *)expression;

- (void)setOrder:(TCTableDBQueryOrder)order forColumn:(NSString *)name;

- (void)setLimit:(NSInteger)limit skip:(NSInteger)skip;

- (TCList *)searchKeys;

- (NSArray *)searchMaps;

- (BOOL)remove;

- (NSString *)hint;

@end
