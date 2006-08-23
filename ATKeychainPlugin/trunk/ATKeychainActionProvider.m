//
//  ATKeychainActionProvider.m
//  ATKeychainPlugin
//
//  Created by Alastair on 22/08/2006.
//  Copyright 2006 liquidx.net. All rights reserved.
//

#import "ATKeychainActionProvider.h"


@implementation ATKeychainActionProvider

- (void) copyFromObject:(QSObject *)dObject keychainField:(SecItemAttr)tag
{
	// obtain attributes from KeychainItem
	SecKeychainItemRef itemRef = nil;
	ATKeychainItemObject *keychainItem = nil;
	
	OSStatus status = 0;
	SecKeychainAttribute attributes[1];
	attributes[0].tag = tag;
	attributes[0].length = 0;
	
	if ([[dObject primaryType] isEqualTo:kATKeychainItemType]) {
		keychainItem = (ATKeychainItemObject *)dObject;
		itemRef = (SecKeychainItemRef)[dObject objectForType:kATKeychainItemType];
	}
	
	if (itemRef) {
		SecKeychainAttributeList attrList = {1, attributes};
		status = SecKeychainItemCopyContent(itemRef,
											NULL,
											&attrList,
											NULL, NULL); // for no password
	
		[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
											 owner:self];
		[[NSPasteboard generalPasteboard] setString:[NSString stringWithCString:(char *)attributes[0].data 
																		 length:attributes[0].length] 
											forType:NSStringPboardType];
	}
}

- (QSObject *) copyComment:(QSObject *)dObject
{
	[self copyFromObject:dObject keychainField:kSecCommentItemAttr];
	return nil;
	
}

- (QSObject *) copyAccountName:(QSObject *)dObject
{
	[self copyFromObject:dObject keychainField:kSecAccountItemAttr];
	return nil;
}

- (QSObject *) copyPassword:(QSObject *)dObject
{
	SecKeychainItemRef itemRef = nil;
	ATKeychainItemObject *keychainItem = nil;
	
	if ([[dObject primaryType] isEqualTo:kATKeychainItemType]) {
		keychainItem = (ATKeychainItemObject *)dObject;
		itemRef = (SecKeychainItemRef)[dObject objectForType:kATKeychainItemType];
	}
	
	if (itemRef) {
		UInt32 plen = 0;
		char *pword;
		OSStatus status;
		
		status = SecKeychainItemCopyContent(itemRef,
											NULL,
											NULL,
											&plen, 
											(void **)&pword);
		if (status != noErr) {
			return nil;
		}
		
		[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
												 owner:self];
		[[NSPasteboard generalPasteboard] setString:[NSString stringWithCString:pword length:plen] 
											forType:NSStringPboardType];
		
		SecKeychainItemFreeContent(NULL, pword);
	}
	
	
	return nil;
}

- (QSObject *) openKeychain:(QSObject *)dObject
{
	SecKeychainItemRef itemRef = nil;
	SecKeychainRef keychainRef = nil;
	OSStatus status;
	NSString *pathString;
	char path[1024];
	UInt32 pathLen = 1024;
	
	if ([[dObject primaryType] isEqualTo:kATKeychainItemType]) {
		itemRef = (SecKeychainItemRef)[dObject objectForType:kATKeychainItemType];
		if (itemRef) {
			status = SecKeychainItemCopyKeychain(itemRef, &keychainRef);
			if (status != noErr) {
				return nil;
			}
			
			status = SecKeychainGetPath(keychainRef, &pathLen, path);
			if (status != noErr) {
				CFRelease(keychainRef);
				return nil;
			}
			
			pathString = [NSString stringWithCString:path length:pathLen];

			//NSLog(@"ATKeychain: open: %@", pathString);
			
			[[NSWorkspace sharedWorkspace] openFile:pathString];
			CFRelease(keychainRef);
		}
	}
	
	return nil;
}

- (QSObject *) lockKeychain:(QSObject *)dObject
{
	SecKeychainLockAll();
	return nil;
}

- (QSObject *) clearClipboard:(QSObject *)dObject
{
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType]
											 owner:self];
	[[NSPasteboard generalPasteboard] setString:@""
										forType:NSStringPboardType];
	return nil;
}


@end
