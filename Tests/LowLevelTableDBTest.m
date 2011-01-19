#import <GHUnit/GHUnit.h>

#import <TokyoCabinet/tcutil.h>
#import <TokyoCabinet/tctdb.h>

@interface LowLevelTableDBTest : GHTestCase { }
    TCTDB *tdb;
    int ret, ecode;
@end

@implementation LowLevelTableDBTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    /* create the object */
    tdb = tctdbnew();

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/tdb.tct", [paths objectAtIndex:0]];
    GHTestLog(@"path: %@", path);

    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];

    /* open the database */
    if (!tctdbopen(tdb, [path UTF8String], TDBOWRITER | TDBOCREAT)) {
        ecode = tctdbecode(tdb);
        GHTestLog(@"open error: %s\n", tctdberrmsg(ecode));
    }
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    /* close the database */
    if (!tctdbclose(tdb)) {
        ecode = tctdbecode(tdb);
        GHTestLog(@"close error: %s\n", tctdberrmsg(ecode));
    }

    /* delete the object */
    tctdbdel(tdb);
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (void)testTableDBOpened {
    GHAssertNotNULL(tdb, nil);
}

- (void)testStoreAndSearch {
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
}

@end
