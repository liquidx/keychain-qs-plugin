//
//  ATKeychainObjectSource.m
//  ATKeychainPlugin
//
//  Created by Alastair on 22/08/2006.
//  Copyright 2006 liquidx.net. All rights reserved.
//

#import "ATKeychainObjectSource.h"


@implementation ATKeychainObjectSource

//QSObjectSourceInformalProtocol
- (BOOL)isVisibleSource
{
	//NSLog(@"ATKeychain: isVisibleSource:");
	return YES;
}

// QSObkectSourceInformalProtocol
- (BOOL)entryCanBeIndexed:(NSDictionary *)theEntry
{
	//NSLog(@"ATKeychain: entryCanBeIndexed:");
	return YES;
}


// QSObjectSource
- (NSImage *) iconForEntry:(NSDictionary *)theEntry
{
    return [QSResourceManager imageNamed:@"com.apple.keychainaccess"];
}

//QSObjectSource
// - Given an entry (QSPresetAddition) or QSObject, return a list of objects.
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry 
{
	return [ATKeychainPlugin allKeychainItemsAsQSObjects];
}


//QSObjectSource
- (BOOL) indexIsValidFromDate:(NSDate *)indexDate
					 forEntry:(NSDictionary *)theEntry
{
	//NSLog(@"ATKeychain: indexIsValid: %@", indexDate);
	static BOOL hasInitialised = NO;
	if (hasInitialised) {
		NSDate *laterDate = [indexDate laterDate:[ATKeychainPlugin mostRecentKeychainUpdate]];
		if ([laterDate isEqualToDate:indexDate])
			return YES;
		return NO;
	}
	else {
		hasInitialised = YES;
		return NO;
	}
}

//QSObjectSource
- (void) populateFields
{
	//NSLog(@"ATKeychain: populateFields");
}

@end
