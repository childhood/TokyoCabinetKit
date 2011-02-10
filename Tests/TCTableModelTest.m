#import <objc/runtime.h>
#import <GHUnit/GHUnit.h>
#import <TokyoCabinet/TokyoCabinet.h>

@interface Foo : NSObject <TCCoding> {
    int val;
}

@property (nonatomic, assign) int val;

@end

@implementation Foo

@synthesize val;

- (id)initWithVal:(int)aVal {
    if ((self = [super init])) {
        self.val = aVal;
    }
    return self;
}

+ (id)decodeFromTC:(NSString *)str {
    Foo *f = nil;
    if (str) {
        f = [[[[self class] alloc] initWithVal:[str intValue]] autorelease];
    }
    return f;
}

- (NSString *)encodeForTC {
    return [NSString stringWithFormat:@"%d", val];
}

@end

@protocol SampleModel

@optional
+ (id)findByProp:(NSString *)prop;
+ (id)findByFoo:(Foo *)foo;
+ (id)findByI:(int)i;
+ (id)findByD:(double)d;

@end

@interface SampleModel : TCTableModel <SampleModel> {
@private
    NSString *regularProperty;
}

@property (nonatomic, retain) NSString *regularProperty;

@property (nonatomic, assign) NSString *prop;
@property (nonatomic, assign) NSString *p;
@property (nonatomic) BOOL b;
@property (nonatomic) int i;
@property (nonatomic) short s;
@property (nonatomic) long l;
@property (nonatomic) long long ll;
@property (nonatomic) unsigned char uc;
@property (nonatomic) unsigned int ui;
@property (nonatomic) unsigned short us;
@property (nonatomic) unsigned long ul;
@property (nonatomic) unsigned long long ull;
@property (nonatomic) float f;
@property (nonatomic) double d;
@property (nonatomic) NSInteger nsi;
@property (nonatomic, assign) Foo *foo;

@end

@implementation SampleModel

@synthesize regularProperty;

@dynamic prop;
@dynamic p;
@dynamic b, i, s, l, ll, uc, ui, us, ul, ull, f, d, nsi;
@dynamic foo;

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
    [SampleModel removeAllObjects];
    [SampleModel close];
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

- (void)testCustomClass {
    SampleModel *model = [[SampleModel alloc] init];
    GHAssertNil(model.foo, nil);
    model.foo = [[[Foo alloc] initWithVal:3] autorelease];
    GHAssertEquals(3, model.foo.val, nil);
}

- (void)testSimpleFind {
    SampleModel *model = [SampleModel model];
    model.prop = @"aaa";
    Foo *foo = [[[Foo alloc] initWithVal:5] autorelease];
    model.foo = foo;
    model.i = 5;
    model.d = 3.7;
    GHAssertEquals((uint64_t)0, [SampleModel count], nil);
    [model save];
    GHAssertEquals((uint64_t)1, [SampleModel count], nil);

    [SampleModel tuneBnum:10 apow:-1 fpow:-1 opts:TCTableDBOptionDeflate];
    [SampleModel close];

    model = [SampleModel findByKey:@"1"];
    GHAssertNotNil(model, nil);

    model = [SampleModel find:@"aab" by:@"prop"];
    GHAssertNil(model, nil);

    model = [SampleModel find:@"aaa" by:@"prop"];
    GHAssertNotNil(model, nil);

    model = [SampleModel findByProp:@"aaa"];
    GHAssertNotNil(model, nil);

    model = [SampleModel find:foo by:@"foo"];
    GHAssertNotNil(model, nil);

    model = [SampleModel findByFoo:foo];
    GHAssertNotNil(model, nil);

    Foo *foo2 = [[[Foo alloc] initWithVal:7] autorelease];
    model = [SampleModel findByFoo:foo2];
    GHAssertNil(model, nil);

    Foo *foo3 = [[[Foo alloc] initWithVal:5] autorelease];
    model = [SampleModel findByFoo:foo3];
    GHAssertNotNil(model, nil);

    model = [SampleModel findByI:5];
    GHAssertNotNil(model, nil);

    model = [SampleModel findByI:3];
    GHAssertNil(model, nil);

    model = [SampleModel findInt:5 by:@"i"];
    GHAssertNotNil(model, nil);

    model = [SampleModel findInt:4 by:@"i"];
    GHAssertNil(model, nil);

    model = [SampleModel findByD:3.7];
    GHAssertNotNil(model, nil);

    model = [SampleModel findByD:3.2];
    GHAssertNil(model, nil);

    model = [SampleModel findDouble:3.7 by:@"d"];
    GHAssertNotNil(model, nil);

    model = [SampleModel findDouble:4.3 by:@"d"];
    GHAssertNil(model, nil);
}

- (void)testQuery {
    SampleModel *model = [SampleModel model];
    model.prop = @"Hello";
    model.foo = [[[Foo alloc] initWithVal:0] autorelease];
    model.i = 5;
    [model save];

    model = [SampleModel model];
    model.prop = @"aaa";
    model.foo = [[[Foo alloc] initWithVal:1] autorelease];
    model.i = 4;
    [model save];

    model = [SampleModel model];
    model.prop = @"bbb";
    model.foo = [[[Foo alloc] initWithVal:2] autorelease];
    model.i = 3;
    [model save];

    model = [SampleModel model];
    model.prop = @"ccc";
    model.foo = [[[Foo alloc] initWithVal:3] autorelease];
    model.i = 2;
    [model save];

    model = [SampleModel model];
    model.prop = @"ddd";
    model.foo = [[[Foo alloc] initWithVal:4] autorelease];
    model.i = 1;
    [model save];

    model = [SampleModel model];
    model.prop = @"eee";
    model.foo = [[[Foo alloc] initWithVal:5] autorelease];
    model.i = 0;
    [model save];

    GHAssertEquals((uint64_t)6, [SampleModel count], nil);

    TCTableDBQuery *query = [TCTableDBQuery queryWithTableDB:[SampleModel tdb]];
    [query addConditionForColumn:@"prop" stringIncludes:@"o"];
    [query setOrder:TCTableDBQueryOrderNumberAsc forColumn:@"i"];
    NSArray *models = [SampleModel search:query];
    GHAssertEquals((NSUInteger)1, models.count, nil);
    model = [models objectAtIndex:0];
    GHAssertEqualStrings(@"Hello", model.prop, nil);

    query = [TCTableDBQuery queryWithTableDB:[SampleModel tdb]];
    [query addConditionForColumn:@"prop" stringIncludes:@"e"];
    [query setOrder:TCTableDBQueryOrderNumberAsc forColumn:@"i"];
    models = [SampleModel search:query];
    GHAssertEquals((NSUInteger)2, models.count, nil);
    model = [models objectAtIndex:0];
    GHAssertEqualStrings(@"eee", model.prop, nil);
    model = [models objectAtIndex:1];
    GHAssertEqualStrings(@"Hello", model.prop, nil);
}

@end
