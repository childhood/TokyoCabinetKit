/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import "ComValleyportTiTokyocabinetTableDBProxy.h"

@interface ComValleyportTiTokyocabinetModule : TiModule {
}

//@property (nonatomic, assign) NSString *exampleProp;

@property (nonatomic, readonly) NSNumber *TDBOWRITER;
@property (nonatomic, readonly) NSNumber *TDBOREADER;
@property (nonatomic, readonly) NSNumber *TDBOCREAT;
@property (nonatomic, readonly) NSNumber *TDBOTRUNC;
@property (nonatomic, readonly) NSNumber *TDBOTSYNC;
@property (nonatomic, readonly) NSNumber *TDBONOLCK;
@property (nonatomic, readonly) NSNumber *TDBOLCKNB;

- (id)createTableDB:(id)args;

@end
