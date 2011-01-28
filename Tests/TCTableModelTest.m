#import <GHUnit/GHUnit.h>

#import <TokyoCabinet/TCTableModel.h>

@interface SampleModel : TCTableModel {
@private
    NSString *regularProperty;
}

@property (nonatomic, retain) NSString *regularProperty;

@property (nonatomic, assign) NSString *prop;
@property (nonatomic, assign) NSString *p;

@end

@implementation SampleModel

@synthesize regularProperty;

@dynamic prop;
@dynamic p;

+ (id)model {
    return [[[[self class] alloc] init] autorelease];
}

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
}

@end

@implementation TCTableModelTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/SampleModel.tct", [paths objectAtIndex:0]];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
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

- (void)testDynamicProperty {
    SampleModel *model = [SampleModel model];
    GHAssertNil(model.prop, nil);
    model.prop = @"a prop";
    GHAssertEqualStrings(@"a prop", model.prop, nil);

    GHAssertNil(model.p, nil);
    model.p = @"1 character";
    GHAssertEqualStrings(@"1 character", model.p, nil);
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

@end
