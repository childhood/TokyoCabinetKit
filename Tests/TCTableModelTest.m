#import <objc/runtime.h>
#import <GHUnit/GHUnit.h>
#import <TokyoCabinet/TCTableModel.h>

@interface SampleModel : TCTableModel {
@private
    NSString *regularProperty;
}

@property (nonatomic, retain) NSString *regularProperty;

@property (nonatomic, assign) NSString *prop;
@property (nonatomic, assign) NSString *p;
@property (nonatomic, assign) BOOL b;
@property (nonatomic, assign) int i;
@property (nonatomic, assign) short s;
@property (nonatomic, assign) long l;
@property (nonatomic, assign) long long ll;
@property (nonatomic, assign) unsigned char uc;
@property (nonatomic, assign) unsigned int ui;
@property (nonatomic, assign) unsigned short us;
@property (nonatomic, assign) unsigned long ul;
@property (nonatomic, assign) unsigned long long ull;
@property (nonatomic, assign) float f;
@property (nonatomic, assign) double d;
@property (nonatomic, assign) NSInteger nsi;

@end

@implementation SampleModel

@synthesize regularProperty;

@dynamic prop;
@dynamic p;
@dynamic b, i, s, l, ll, uc, ui, us, ul, ull, f, d, nsi;

- (id)init {
    if ((self = [super init])) {
        self.regularProperty = @"regular property";
    }
    return self;
}

- (void)dealloc {
    [regularProperty release];

    [super dealloc];
}

@end

@interface TCTableModelTest : GHTestCase {
    NSString *path;
}

@end

@implementation TCTableModelTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    [SampleModel close];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [NSString stringWithFormat:@"%@/SampleModel.tct", [paths objectAtIndex:0]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    [SampleModel close];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (void)testTableDB {
    TCTableDB *tdb = nil;
    GHAssertNil(tdb, nil);
    tdb = [SampleModel tdb];
    GHAssertNotNil(tdb, nil);
}

- (void)testRegularProperty {
    SampleModel *model = [SampleModel model];
    GHAssertEqualStrings(@"regular property", model.regularProperty, nil);
    model.regularProperty = @"changed";
    GHAssertEqualStrings(@"changed", model.regularProperty, nil);
}

- (void)testKey {
    SampleModel *model = [SampleModel model];
    GHAssertNil(model.key, nil);
    [model assignKey];
    GHAssertNotNil(model.key, nil);
    GHTestLog(@"key: %@", model.key);
}

- (void)testKeyValueCoding {
    SampleModel *model = [SampleModel model];
    GHAssertNil([model valueForKey:@"property"], nil);

    // set
    [model setValue:@"set property" forKey:@"property"];
    GHAssertEqualStrings([model valueForKey:@"property"], @"set property", nil);

    // remove
    [model setValue:nil forKey:@"property"];
    GHAssertNil([model valueForKey:@"property"], nil);
}

- (void)testDynamicProperty {
    SampleModel *model = [SampleModel model];
    GHAssertNil(model.prop, nil);
    model.prop = @"a prop";
    GHAssertEqualStrings(@"a prop", model.prop, nil);

    GHAssertNil(model.p, nil);
    model.p = @"1 character";
    GHAssertEqualStrings(@"1 character", model.p, nil);
}

- (void)testDynamicType {
    SampleModel *model = [[SampleModel alloc] init];
    GHAssertNil(model.key, nil);
    GHAssertEquals(NO, model.b, nil);
    model.b = YES;
    GHAssertEquals(YES, model.b, nil);

    GHAssertEquals(0, model.i, nil);
    model.i = 11;
    GHAssertEquals(11, model.i, nil);

    GHAssertEquals((short)0, model.s, nil);
    model.s = 12;
    GHAssertEquals((short)12, model.s, nil);

    GHAssertEquals((long)0, model.l, nil);
    model.l = 13;
    GHAssertEquals((long)13, model.l, nil);

    GHAssertEquals((long long)0, model.ll, nil);
    model.ll = 14;
    GHAssertEquals((long long)14, model.ll, nil);

    GHAssertEquals((unsigned char)0, model.uc, nil);
    model.uc = 15;
    GHAssertEquals((unsigned char)15, model.uc, nil);

    GHAssertEquals((unsigned)0, model.ui, nil);
    model.ui = 16;
    GHAssertEquals((unsigned)16, model.ui, nil);

    GHAssertEquals((unsigned short)0, model.us, nil);
    model.us = 17;
    GHAssertEquals((unsigned short)17, model.us, nil);

    GHAssertEquals((unsigned long)0, model.ul, nil);
    model.ul = 18;
    GHAssertEquals((unsigned long)18, model.ul, nil);

    GHAssertEquals((unsigned long long)0, model.ull, nil);
    model.ull = 19;
    GHAssertEquals((unsigned long long)19, model.ull, nil);

    GHAssertEquals((float)0.0, model.f, nil);
    model.f = 1.1;
    GHAssertEquals((float)1.1, model.f, nil);

    GHAssertEquals((double)0, model.d, nil);
    model.d = 2.2;
    GHAssertEquals((double)2.2, model.d, nil);

    GHAssertEquals((NSInteger)0, model.nsi, nil);
    model.nsi = 20;
    GHAssertEquals((NSInteger)20, model.nsi, nil);

    [model save];
    NSString *key = [model.key retain];
    [model release];
    model = nil;

    [SampleModel sync];
    [SampleModel close];

    model = [SampleModel findByKey:key];
    GHAssertEqualStrings(key, model.key, nil);
    GHAssertEquals((NSInteger)20, model.nsi, nil);

    [key release];
}

@end
