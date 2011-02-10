#import <sys/time.h>
#import <GHUnit/GHUnit.h>
#import <TokyoCabinet/NSObject+TCCoding.h>
#import <TokyoCabinet/TCList.h>

@interface ListTest : GHTestCase {
}

@end

@implementation ListTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (void)testAddAndRemove {
    TCList *list = [TCList list];
    GHAssertEquals(0, list.count, nil);

    [list addObject:@"aaa"];
    GHAssertEquals(1, list.count, nil);

    [list addObject:@"bbb"];
    GHAssertEquals(2, list.count, nil);

    [list addObject:@"ccc"];
    GHAssertEquals(3, list.count, nil);

    GHAssertEqualStrings(@"bbb", [list objectAtIndex:1], nil);

    NSString *ccc = [list popObject];
    GHAssertEqualStrings(@"ccc", ccc, nil);
    GHAssertEquals(2, list.count, nil);

    [list unshiftObject:@"ddd"];
    GHAssertEquals(3, list.count, nil);
    GHAssertEqualStrings(@"ddd", [list objectAtIndex:0], nil);
    GHAssertEqualStrings(@"aaa", [list objectAtIndex:1], nil);

    NSString *ddd = [list shiftObject];
    GHAssertEqualStrings(@"ddd", ddd, nil);
    GHAssertEquals(2, list.count, nil);
    GHAssertEqualStrings(@"aaa", [list objectAtIndex:0], nil);

    [list insertObject:@"eee" atIndex:1];
    GHAssertEquals(3, list.count, nil);
    GHAssertEqualStrings(@"aaa", [list objectAtIndex:0], nil);
    GHAssertEqualStrings(@"eee", [list objectAtIndex:1], nil);
    GHAssertEqualStrings(@"bbb", [list objectAtIndex:2], nil);

    [list removeObjectAtIndex:1];
    GHAssertEquals(2, list.count, nil);
    GHAssertEqualStrings(@"aaa", [list objectAtIndex:0], nil);
    GHAssertEqualStrings(@"bbb", [list objectAtIndex:1], nil);

    [list replaceObjectAtIndex:1 withObject:@"fff"];
    GHAssertEquals(2, list.count, nil);
    GHAssertEqualStrings(@"aaa", [list objectAtIndex:0], nil);
    GHAssertEqualStrings(@"fff", [list objectAtIndex:1], nil);

    [list removeAllObjects];
    GHAssertEquals(0, list.count, nil);
}

- (void)testEnumeration {
    TCList *list = [TCList list];
    [list addObject:@"aaa"];
    [list addObject:@"bbb"];
    [list addObject:@"ccc"];
    [list addObject:@"ddd"];
    [list addObject:@"eee"];

    int i = 0;
    for (NSString *str in list) {
        //GHTestLog(@"str: %@", str);
        GHAssertEqualStrings(str, [list objectAtIndex:i], nil);
        i += 1;
    }
}

@end
