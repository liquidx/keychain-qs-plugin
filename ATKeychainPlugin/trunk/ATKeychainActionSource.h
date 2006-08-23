//
//  ATKeychainActionSource.h
//  ATKeychainPlugin
//
//  Created by Alastair on 23/08/2006.
//  Copyright 2006 liquidx.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ATKeychainActionProvider.h"

@interface ATKeychainActionSource : QSObjectSource {
	NSArray *actions;
}

@end
