#import <GHUnit/GHUnit.h>

#import <TokyoCabinet/TCTableDB.h>

@interface TableDBTest : GHTestCase { }
    TCTableDB *tdb;
@end

@implementation TableDBTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/tctdb.tct", [paths objectAtIndex:0]];
    GHTestLog(@"path: %@", path);
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    tdb = [TCTableDB dbWithFile:path];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    //[tdb release];
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (void)testStoreAndSearch {
    [tdb removeAllObjects];

    NSString *key = [NSString stringWithFormat:@"%ld", (long)[tdb generateUniqueId]];
    TCMap *cols = [TCMap map];
    [cols setObject:@"yatsu" forKey:@"name"];
    [cols setObject:@"34" forKey:@"age"];
    [cols setObject:@"ja,de,objc" forKey:@"lang"];
    [tdb setMap:cols forKey:key];

    GHAssertEquals((uint64_t)1, tdb.count, nil);

    cols = [TCMap map];
    [cols setObject:@"falcon" forKey:@"name"];
    [cols setObject:@"31" forKey:@"age"];
    [cols setObject:@"ja" forKey:@"lang"];
    [tdb setMap:cols forKey:@"12345"];

    GHAssertEquals((uint64_t)2, tdb.count, nil);

    [tdb setMapFromTabSeparatedString:@"name\tjoker\tage\t19\tlang\ten,es" forKey:@"abcde"];

    GHAssertEquals((uint64_t)3, tdb.count, nil);

    cols = [tdb mapForKey:key];
    GHAssertEqualStrings(@"yatsu", [cols objectForKey:@"name"], nil);
    GHAssertEqualStrings(@"34", [cols objectForKey:@"age"], nil);
    GHAssertEqualStrings(@"ja,de,objc", [cols objectForKey:@"lang"], nil);

    cols = [tdb mapForKey:@"12345"];
    GHAssertEqualStrings(@"falcon", [cols objectForKey:@"name"], nil);
    GHAssertEqualStrings(@"31", [cols objectForKey:@"age"], nil);
    GHAssertEqualStrings(@"ja", [cols objectForKey:@"lang"], nil);

    cols = [tdb mapForKey:@"abcde"];
    GHAssertEqualStrings(@"joker", [cols objectForKey:@"name"], nil);
    GHAssertEqualStrings(@"19", [cols objectForKey:@"age"], nil);
    GHAssertEqualStrings(@"en,es", [cols objectForKey:@"lang"], nil);

    TCTableDBQuery *query = [TCTableDBQuery queryWithTableDB:tdb];
    [query addConditionForColumn:@"age" numberGreaterThanOrEqual:[NSNumber numberWithInteger:20]];
    [query setOrder:TCTableDBQueryOrderStringAsc forColumn:@"name"];
    [query setLimit:100 skip:0];

    TCList *list = [query searchKeys];
    GHAssertEquals(2, list.count, nil);
    GHAssertEqualStrings(@"12345", [list objectAtIndex:0], nil);
    GHAssertEqualStrings(@"1", [list objectAtIndex:1], nil);

    NSArray *maps = [query searchMaps];
    GHAssertEquals((NSUInteger)2, maps.count, nil);

    cols = [maps objectAtIndex:0];
    GHTestLog(@"match 0: %@", cols);
    GHAssertEqualStrings(@"falcon", [cols objectForKey:@"name"], nil);

    cols = [maps objectAtIndex:1];
    GHTestLog(@"match 1: %@", cols);
    GHAssertEqualStrings(@"yatsu", [cols objectForKey:@"name"], nil);

    query = [TCTableDBQuery queryWithTableDB:tdb];
    [query addConditionForColumn:@"age" numberLessThan:[NSNumber numberWithFloat:20.5]];
    [query setOrder:TCTableDBQueryOrderStringAsc forColumn:@"name"];
    [query setLimit:100 skip:0];

    list = [query searchKeys];
    GHAssertEquals(1, list.count, nil);
    GHAssertEqualStrings(@"abcde", [list objectAtIndex:0], nil);

    maps = [query searchMaps];
    GHAssertEquals((NSUInteger)1, maps.count, nil);

    cols = [maps objectAtIndex:0];
    GHTestLog(@"match 0: %@", cols);
    GHAssertEqualStrings(@"joker", [cols objectForKey:@"name"], nil);
}

- (void)testFullTextSearch {
    [tdb removeAllObjects];

    NSString *key = [NSString stringWithFormat:@"%ld", (long)[tdb generateUniqueId]];
    TCMap *cols = [TCMap map];
    [cols setObject:@"yatsu" forKey:@"name"];
    [cols setObject:@"34" forKey:@"age"];
    [cols setObject:@"Programming is my hobby" forKey:@"memo"];
    [tdb setMap:cols forKey:key];

    GHAssertEquals((uint64_t)1, tdb.count, nil);

    cols = [TCMap map];
    [cols setObject:@"falcon" forKey:@"name"];
    [cols setObject:@"31" forKey:@"age"];
    [cols setObject:@"I like cooking" forKey:@"memo"];
    [tdb setMap:cols forKey:@"12345"];

    GHAssertEquals((uint64_t)2, tdb.count, nil);

    cols = [TCMap map];
    [cols setObject:@"joker" forKey:@"name"];
    [cols setObject:@"19" forKey:@"age"];
    [cols setObject:@"I am a programmer" forKey:@"memo"];
    [tdb setMap:cols forKey:@"abcde"];

    GHAssertEquals((uint64_t)3, tdb.count, nil);

    TCTableDBQuery *query = [TCTableDBQuery queryWithTableDB:tdb];
    [query addConditionForColumn:@"memo" stringIncludes:@"program"];
    [query setOrder:TCTableDBQueryOrderStringDesc forColumn:@"name"];
    NSArray *maps = [query searchMaps];
    GHAssertEquals((NSUInteger)1, maps.count, nil);
    cols = [maps objectAtIndex:0];
    GHAssertEqualStrings(@"joker", [cols objectForKey:@"name"], nil);

    [tdb setIndex:TCTableDBIndexQGram forColumn:@"memo"];
    [tdb optimizeIndexForColumn:@"memo"];

    query = [TCTableDBQuery queryWithTableDB:tdb];
    [query addConditionForColumn:@"memo" fullTextPhrase:@"program"];
    [query setOrder:TCTableDBQueryOrderNumberAsc forColumn:@"age"];
    maps = [query searchMaps];
    GHAssertEquals((NSUInteger)2, maps.count, nil);
    cols = [maps objectAtIndex:0];
    GHAssertEqualStrings(@"joker", [cols objectForKey:@"name"], nil);
    cols = [maps objectAtIndex:1];
    GHAssertEqualStrings(@"yatsu", [cols objectForKey:@"name"], nil);

    query = [TCTableDBQuery queryWithTableDB:tdb];
    [query addConditionForColumn:@"memo" fullTextPhrase:@"hobby"];
    maps = [query searchMaps];
    GHAssertEquals((NSUInteger)1, maps.count, nil);
    cols = [maps objectAtIndex:0];
    GHAssertEqualStrings(@"yatsu", [cols objectForKey:@"name"], nil);
}

@end
