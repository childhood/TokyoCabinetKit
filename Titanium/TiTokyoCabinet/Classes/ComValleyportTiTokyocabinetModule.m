/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComValleyportTiTokyocabinetModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation ComValleyportTiTokyocabinetModule

#pragma mark System Properties

MAKE_SYSTEM_PROP_DBL(TDBOWRITER, TDBOWRITER);
MAKE_SYSTEM_PROP_DBL(TDBOREADER, TDBOREADER);
MAKE_SYSTEM_PROP_DBL(TDBOCREAT, TDBOCREAT);
MAKE_SYSTEM_PROP_DBL(TDBOTRUNC, TDBOTRUNC);
MAKE_SYSTEM_PROP_DBL(TDBOTSYNC, TDBOTSYNC);
MAKE_SYSTEM_PROP_DBL(TDBONOLCK, TDBONOLCK);
MAKE_SYSTEM_PROP_DBL(TDBOLCKNB, TDBOLCKNB);

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID {
    return @"bd88ad46-4c3f-4e03-a8bf-dc0f534d4c71";
}

// this is generated for your module, please do not change it
- (NSString *)moduleId {
    return @"com.valleyport.ti.tokyocabinet";
}

#pragma mark Lifecycle

- (void)startup {
    // this method is called when the module is first loaded
    // you *must* call the superclass
    [super startup];

    NSLog(@"[INFO] %@ loaded",self);
}

- (void)shutdown:(id)sender {
    // this method is called when the module is being unloaded
    // typically this is during shutdown. make sure you don't do too
    // much processing here or the app will be quit forceably

    // you *must* call the superclass
    [super shutdown:sender];
}

#pragma mark Cleanup

- (void)dealloc {
    // release any resources that have been retained by the module
    [super dealloc];
}

#pragma mark Internal Memory Management

- (void)didReceiveMemoryWarning:(NSNotification*)notification {
    // optionally release any resources that can be dynamically
    // reloaded once memory is available - such as caches
    [super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

- (void)_listenerAdded:(NSString *)type count:(int)count {
    if (count == 1 && [type isEqualToString:@"my_event"]) {
        // the first (of potentially many) listener is being added
        // for event named 'my_event'
    }
}

- (void)_listenerRemoved:(NSString *)type count:(int)count {
    if (count == 0 && [type isEqualToString:@"my_event"]) {
        // the last listener called for event named 'my_event' has
        // been removed, we can optionally clean up any resources
        // since no body is listening at this point for that event
    }
}

#pragma Public APIs

//- (id)example:(id)args {
//    // example method
//    return @"example";
//}
//
//- (id)exampleProp {
//    // example property getter
//    return @"prop";
//}

//- (void)exampleProp:(id)value {
//    // example property setter
//}

- (id)createTableDB:(id)args {
    ComValleyportTiTokyocabinetTableDBProxy *tdb;

    if ([args count] >= 1) {
        id arg = [args objectAtIndex:0];
        ENSURE_STRING(arg);
        NSString *file = [TiUtils stringValue:arg];

        int mode;
        if ([args count] >= 2) {
            arg = [args objectAtIndex:1];
            ENSURE_TYPE(arg, NSNumber);
            mode = [TiUtils intValue:arg];
        } else {
            mode = TCTableDBOpenModeReader |
                   TCTableDBOpenModeWriter |
                   TCTableDBOpenModeCreate;
        }

        tdb = [ComValleyportTiTokyocabinetTableDBProxy dbWithFile:file mode:mode];
    } else {
        tdb = [ComValleyportTiTokyocabinetTableDBProxy db];
    }

    return tdb;
}

@end
