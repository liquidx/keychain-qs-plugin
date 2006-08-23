//
//  ATKeychainActionSource.m
//  ATKeychainPlugin
//
//  Created by Alastair on 23/08/2006.
//  Copyright 2006 liquidx.net. All rights reserved.
//

#import "ATKeychainActionSource.h"


@implementation ATKeychainActionSource

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry
{
	NSMutableArray *objects = [NSMutableArray array];
	
	QSObject *lockAction, *clearAction, *unlockAction;
	NSDictionary *lockDict, *clearDict, *unlockDict;
	
	lockDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([ATKeychainActionProvider class]),
		kActionClass,
		@"lockKeychain:",
		kActionSelector,
		@"Lock All Keychains",
		kActionName,
		@"com.apple.keychainaccess",
		kActionIcon,
		nil];
	
	[objects addObject:[QSAction actionWithDictionary:lockDict
										   identifier:kATKeychainLockAction
											   bundle:nil]];
	
	clearDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([ATKeychainActionProvider class]),
		kActionClass,
		@"clearClipboard:",
		kActionSelector,
		@"Clear Clipboard",
		kActionName,
		@"com.apple.keychainaccess",
		kActionIcon,
		nil];
	
	[objects addObject:[QSAction actionWithDictionary:clearDict
										   identifier:kATKeychainClearClipboardAction
											   bundle:nil]];
	
	return objects;
}

// QSObjectSource
- (NSImage *) iconForEntry:(NSDictionary *)theEntry
{
    return [QSResourceManager imageNamed:@"com.apple.keychainaccess"];
}
@end
