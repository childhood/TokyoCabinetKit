#import <sys/time.h>
#import <GHUnit/GHUnit.h>

#import <TokyoCabinet/TCMap.h>

unsigned int g_randseed;

void sysprint(void){
    TCMAP *info = tcsysinfo();
    if (info) {
        tcmapiterinit(info);
        const char *kbuf;
        while ((kbuf = tcmapiternext2(info)) != NULL) {
            NSLog(@"sys_%s: %s", kbuf, tcmapiterval2(kbuf));
        }
        tcmapdel(info);
    }
}

double tctime(void);

int myrand(int range) {
    if (range < 2) return 0;
    int high = (unsigned int)rand() >> 4;
    int low = range * (rand() / (RAND_MAX + 1.0));
    low &= (unsigned int)INT_MAX >> 4;
    return (high + low) % range;
}

@interface MapTest : GHTestCase { }
    TCMap *map;
@end

@implementation MapTest

- (NSInteger)procMapWithRnum:(int)rnum bnum:(int)bnum rd:(BOOL)rd tr:(BOOL)tr rnd:(BOOL)rnd dmode:(int)dmode {
    GHTestLog(@"<Map Writing Test>\n  seed=%u  rnum=%d  bnum=%d  rd=%d  tr=%d  rnd=%d  dmode=%d",
              g_randseed, rnum, bnum, rd, tr, rnd, dmode);
    double stime = tctime();
    TCMap *map;
    if (bnum > 0)
        map = [[TCMap alloc] initWithNumber:bnum];
    else
        map = [[TCMap alloc] init];
    for (int i = 1; i <= rnum; i++) {
        NSString *str = [[NSString alloc] initWithFormat:@"%08d", rnd ? myrand(rnum) + 1 : i];
        switch (dmode) {
            case -1:
                [map setObject:str forKey:str keep:YES];
                break;
            case 1:
                [map catObject:str forKey:str];
                break;
            case 10:
                [map addInteger:myrand(3) forKey:str];
                break;
            case 11:
                [map addDouble:myrand(3) forKey:str];
                break;
            case 12:
                //tcmapputproc(map, buf, len, buf, len, pdprocfunc, NULL);
                break;
            default:
                //GHTestLog(@"set key: %@ object: %@", str, str);
                [map setObject:str forKey:str];
                break;
        }
        [str release];
        if (rnum > 250 && i % (rnum / 250) == 0) {
            //GHTestLog(@".");
            if (i == rnum || i % (rnum / 10) == 0) GHTestLog(@" (%08d)", i);
        }
    }
    if (rd) {
        double itime = tctime();
        GHTestLog(@"time: %.3f", itime - stime);
        stime = itime;
        for (int i = 1; i <= rnum; i++) {
            NSString *key = [[NSString alloc] initWithFormat:@"%08d", rnd ? myrand(rnum) + 1 : i];
            [map objectForKey:key];
            //NSLog(@"rd key: %@ str: %@", key, str);
            if (rnum > 250 && i % (rnum / 250) == 0) {
                //GHTestLog(@".");
                if (i == rnum || i % (rnum / 10) == 0) GHTestLog(@" (%08d)", i);
            }
            [key release];
        }
    }
    if (tr) {
        double itime = tctime();
        GHTestLog(@"time: %.3f", itime - stime);
        stime = itime;
        [map iteratorInit];
        NSString *key;
        int inum = 1;
        while ((key = [map iteratorNext]) != nil) {
            //NSLog(@"tr key: %@", key);
            //tcmapiterval2(kbuf);
            if (rnum > 250 && inum % (rnum / 250) == 0) {
                //GHTestLog(@".");
                if (inum == rnum || inum % (rnum / 10) == 0) GHTestLog(@" (%08d)", inum);
            }
            inum++;
        }
        NSLog(@"done");
        if (rnd && rnum > 250) GHTestLog(@" (%08d)", inum);
    }
    GHTestLog(@"record number: %llu", (unsigned long long)(map.count));
    GHTestLog(@"size: %llu", (unsigned long long)(map.size));
    sysprint();
    [map release];
    GHTestLog(@"time: %.3f", tctime() - stime);
    GHTestLog(@"ok");
    return 0;
}

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

- (void)testMapStore {
    //- (NSInteger)procMapWithRnum:(int)rnum bnum:(int)bnum rd:(BOOL)rd tr:(BOOL)tr rnd:(BOOL)rnd dmode:(int)dmode;
    //[self procMapWithRnum:5 bnum:1 rd:YES tr:YES rnd:NO dmode:0];
    //[self procMapWithRnum:10000 bnum:0 rd:YES tr:YES rnd:YES dmode:0];
    [self procMapWithRnum:10000 bnum:0 rd:NO tr:NO rnd:YES dmode:0];
    //[self procMapWithRnum:5 bnum:0 rd:YES tr:YES rnd:YES dmode:0];
}

- (void)testDictionaryStore {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (int i = 1; i <= 10000; i++) {
        NSString *str = [[NSString alloc] initWithFormat:@"%08d", myrand(10000) + 1];
        [dict setObject:str forKey:str];
    }
}

@end
