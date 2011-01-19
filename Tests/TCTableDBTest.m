#import <GHUnit/GHUnit.h>

#import <TokyoCabinet/TCTableDB.h>

@interface TCTableDBTest : GHTestCase { }
    TCTableDB *tdb;
@end

@implementation TCTableDBTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/tctdb.tct", [paths objectAtIndex:0]];
    GHTestLog(@"path: %@", path);

    tdb = [[TCTableDB alloc] initWithFile:path];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    /* close the database */
    [tdb release];
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (void)testTableDBOpened {
    GHAssertNotNULL(tdb, nil);
    GHAssertNotNULL(tdb.tdb, nil);
    GHAssertEquals(0, tdb.ecode, nil);
}

- (void)testStoreAndSearch {
    /*
    char pkbuf[256];
    int pksiz = sprintf(pkbuf, "%ld", (long)tctdbgenuid(tdb));
    TCMAP *cols = tcmapnew3("name", "mikio", "age", "30", "lang", "ja,en,c", NULL);
    if (!tctdbput(tdb, pkbuf, pksiz, cols)) {
        ecode = tctdbecode(tdb);
        GHTestLog(@"put error: %s\n", tctdberrmsg(ecode));
    }
    tcmapdel(cols);

    pksiz = sprintf(pkbuf, "12345");
    cols = tcmapnew();
    tcmapput2(cols, "name", "falcon");
    tcmapput2(cols, "age", "31");
    tcmapput2(cols, "lang", "ja");
    ret = tctdbput(tdb, pkbuf, pksiz, cols);
    if (!ret) {
        ecode = tctdbecode(tdb);
        GHTestLog(@"put error: %s\n", tctdberrmsg(ecode));
    }
    tcmapdel(cols);
    GHAssertNotEquals(0, ret, nil);

    ret = tctdbput3(tdb, "abcde", "name\tjoker\tage\t19\tlang\ten,es");
    if (!ret) {
        ecode = tctdbecode(tdb);
        GHTestLog(@"put error: %s\n", tctdberrmsg(ecode));
    }
    GHAssertNotEquals(0, ret, nil);

    TDBQRY *qry = tctdbqrynew(tdb);
    tctdbqryaddcond(qry, "age", TDBQCNUMGE, "20");
    tctdbqryaddcond(qry, "lang", TDBQCSTROR, "ja,en");
    tctdbqrysetorder(qry, "name", TDBQOSTRASC);
    tctdbqrysetlimit(qry, 10, 0);
    TCLIST *res = tctdbqrysearch(qry);
    for (int i = 0; i < tclistnum(res); i++){
        NSMutableString *str = [NSMutableString string];
        int rsiz;
        const char *rbuf = tclistval(res, i, &rsiz);
        TCMAP *cols = tctdbget(tdb, rbuf, rsiz);
        if (cols) {
            [str appendFormat:@"%s", rbuf];
            tcmapiterinit(cols);
            const char *name;
            while ((name = tcmapiternext2(cols)) != NULL) {
                [str appendFormat:@"\t%s\t%s", name, tcmapget2(cols, name)];
            }
            GHTestLog(@"result: %@\n", str);
            tcmapdel(cols);
        }
    }
    tclistdel(res);
    tctdbqrydel(qry);
    */
}

- (void)testSaveAndLoad {
    /*
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];

    [encoder encodeObject:settings forKey:@"settings"];
    [encoder finishEncoding];

    [theData writeToFile:dataFilePath atomically:YES];
    [encoder release];

    NSMutableData *theData  = [NSMutableData dataWithContentsOfFile:path];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];

    self.settings = [decoder decodeObjectForKey:@"settings"];

    [decoder finishDecoding];
    [decoder release];
    */
}

@end
