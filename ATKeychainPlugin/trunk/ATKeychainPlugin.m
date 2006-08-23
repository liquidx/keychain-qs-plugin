//
//  ATKeychainPlugin.m
//  ATKeychainPlugin
//
//  Created by Alastair on 22/08/2006.
//  Copyright liquidx.net 2006. All rights reserved.
//

#import "ATKeychainPlugin.h"

@implementation ATKeychainPlugin

+ (NSArray *) allKeychains
{
	NSArray *keychainsCopy;
	CFArrayRef keychains;
	OSStatus status;
	
	status = SecKeychainCopySearchList(&keychains);
	if (status != noErr) {
		NSLog(@"ATKeychain: Unable to load keychains: Error %d", status);
		return nil;
	}

	// TODO: probably unnecessarily conservative, but we
	//       make a shallow copy and release the array.
	keychainsCopy = [NSArray arrayWithArray:(NSArray *)keychains];
	CFRelease(keychains);
	return keychainsCopy;
}

+ (NSDate *) mostRecentKeychainUpdate
{
	NSArray *keychains = [ATKeychainPlugin allKeychains];
	NSDate  *mostRecentUpdate = [NSDate dateWithTimeIntervalSince1970:0];
	NSEnumerator *e = [keychains objectEnumerator];
	SecKeychainRef keychain = nil;	
	OSStatus status;
	UInt32 pathLen = 1024;
	char path[1024];
	
	while (keychain = (SecKeychainRef)[e nextObject]) {
		status = SecKeychainGetPath(keychain, &pathLen, path);
		if (status != noErr)
			continue;
		
		NSString *pathString = [NSString stringWithCString:path length:pathLen];
		if (!pathString)
			continue;
		
		NSDate *lastUpdated = [[[NSFileManager defaultManager] 
									fileAttributesAtPath:pathString
											traverseLink:YES] 
										objectForKey:NSFileModificationDate];
		
		mostRecentUpdate = [lastUpdated laterDate:mostRecentUpdate];
	}
	return mostRecentUpdate;
}

+ (NSArray *)allKeychainItemsAsQSObjects
{
	SecItemClass supportedClasses[] = {
		kSecGenericPasswordItemClass,
		kSecInternetPasswordItemClass,
		nil
	};
	
	SecKeychainSearchRef	searchRef = nil;
	SecKeychainItemRef		itemRef = nil;
	OSStatus				status = 0;
	NSMutableArray			*keychainItems = [NSMutableArray array];
	ATKeychainItemObject	*item;
	
	// get all keychains
	NSArray *keychains = [ATKeychainPlugin allKeychains];

	int i = 0;
	for (i = 0; supportedClasses[i] != nil; i++) {
		status = SecKeychainSearchCreateFromAttributes((CFArrayRef)keychains,
													   supportedClasses[i],
													   NULL, &searchRef);
		if (status != noErr) {
			NSLog(@"ATKeychain: Error creating search ref; %d", status);
			continue;
		}
		
		// iterate through the items
		while ((status = SecKeychainSearchCopyNext(searchRef, &itemRef)) != 
			   errSecItemNotFound) {

			if ([ATKeychainItemObject isValidKeychainItem:itemRef]) {
				item = [ATKeychainItemObject keychainItemObject:itemRef];
				if (item)
					[keychainItems addObject:item];
			}
			
			CFRelease(itemRef);
			itemRef = nil;
		}
		
		if (searchRef) {
			CFRelease(searchRef);		
			searchRef = nil;
		}
	}
	return keychainItems;
}

@end 
