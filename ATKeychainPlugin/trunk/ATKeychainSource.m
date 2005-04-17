//
//  ATKeychainModule.m
//  Keychain Module
//
//  Created by Alastair on 27/03/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ATKeychainSource.h"

#define kATKeychainType				@"ATKeychainType"
#define kATKeychainRefType			@"ATKeychainRefType"
#define kATKeychainItemType			@"ATKeychainItemType"
#define kATKeychainItemRefType		@"ATKeychainItemRefType"
#define kATKeychainItemPropertyType @"ATKeychainItemPropertyType"

@implementation ATKeychainSource

- (NSImage *) iconForEntry:(NSDictionary *)dict
{
    return [QSResourceManager imageNamed:@"com.apple.keychainaccess"];
}

- (NSArray *) qsObjectsOfPropertiesOfKeychainItem:(SecKeychainItemRef)keychainItem 
{
	OSStatus status;
	int i;
	NSMutableArray *objects  = [NSMutableArray arrayWithCapacity:1];
	
	// obtain attributes from KeychainItem
	SecKeychainAttribute attributes[4];
	attributes[0].tag = kSecLabelItemAttr;
	attributes[0].length = 0;
	attributes[1].tag = kSecAccountItemAttr;
	attributes[1].length = 0;	
	attributes[2].tag = kSecServiceItemAttr;
	attributes[2].length = 0;	
	attributes[3].tag = kSecCommentItemAttr;
	attributes[3].length = 0;
	
	SecKeychainAttributeList attrList = {4, attributes};
	status = SecKeychainItemCopyContent(keychainItem,
										NULL,
										&attrList,
										NULL, NULL); // for no password
	
	NSArray *attributeTypes = [NSArray arrayWithObjects:@"Name", @"Login", @"Location", @"Comments", nil];
	for (i = 0; i < [attributeTypes count]; i++) {
		if (attributes[i].length > 0) {
			QSObject *newObject = [QSObject objectWithName:[attributeTypes objectAtIndex:i]];
			NSString *stringValue = [NSString stringWithCString:attributes[i].data
														 length:attributes[i].length];
			[newObject setObject:stringValue forType:kATKeychainItemPropertyType];
			[newObject setObject:stringValue forType:QSTextType];
			[newObject setPrimaryType:kATKeychainItemPropertyType];
			[newObject setObject:stringValue forMeta:kQSObjectDetails];
			[objects addObject:newObject];
		}
	}
	return objects;
}

- (NSArray *) qsObjectsOfKeychainItems:(SecKeychainRef)keychain
{
	SecKeychainSearchRef searchRef = nil;
	SecKeychainItemRef itemRef = nil;
	OSStatus status = 0;
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];

	// get items reference from keychsin
	status = SecKeychainSearchCreateFromAttributes(keychain, 
												   kSecGenericPasswordItemClass,
												   NULL,
												   &searchRef);
	
	if (status) {
		printf("error creating search ref: %d\n", status);
		return nil;
	}
	
	// iterate thru all items and create QSObjects
	while((status = SecKeychainSearchCopyNext(searchRef, &itemRef)) != errSecItemNotFound) {
		if (status != noErr) {
			printf("error getting next item reference: %d\n", status);
			break;
		}

		// obtain attributes from KeychainItem
		SecKeychainAttribute attributes[2];
		attributes[0].tag = kSecLabelItemAttr;
		attributes[1].tag = kAccountKCItemAttr;
		
		SecKeychainAttributeList attrList = {2, attributes};
		
		status = SecKeychainItemCopyContent(itemRef,
											NULL,
											&attrList,
											NULL, NULL); // for no password
		
		if (status != noErr) {
			CFRelease(itemRef);			
			break;
		}
		
		// create QSObject for KeychainItem
		NSString *itemName = [NSString stringWithCString:attributes[0].data 
												  length:attributes[0].length];
		NSString *itemAccount = [NSString stringWithCString:attributes[1].data 
													 length:attributes[1].length];

		QSObject *newObject = [QSObject objectWithName:itemName];
		[newObject setObject:itemName forType:kATKeychainItemType];
		[newObject setPrimaryType:kATKeychainItemType];
		[newObject setObject:[@"login:" stringByAppendingString:itemAccount]  forMeta:kQSObjectDetails];
		[newObject setObject:[(NSObject *)itemRef autorelease] forType:kATKeychainItemRefType];
		[objects addObject:newObject];
		
		SecKeychainItemFreeContent(&attrList, NULL);
	}
	
	CFRelease(searchRef);
	return objects;
}

- (NSArray *) qsObjectsOfKeychains
{
	CFArrayRef keychains;
	OSStatus status;
	NSMutableArray *objects;
	int keychainCount, i;
	
	status = SecKeychainCopySearchList(&keychains);
	if (status) {
		NSLog(@"Keychain: Unable to load keychains: %d", status);
		return nil;
	}
	
	// for each keychain, output the path
	objects = [NSMutableArray arrayWithCapacity:1];
	for (i = 0; i < CFArrayGetCount(keychains); i++) {
		UInt32	pathLen = 1024;
		char pathStr[1024];	
		SecKeychainRef keychain = (SecKeychainRef)CFArrayGetValueAtIndex(keychains,i);
		
		status = SecKeychainGetPath(keychain, &pathLen, pathStr);
		if (status != noErr) {
			continue;
		}
		NSString *pathName = [[NSString stringWithCString:pathStr length:pathLen] stringByStandardizingPath];
		NSString *keychainName = [pathName lastPathComponent];
		QSObject *newObject = [QSObject objectWithName:keychainName];
		[newObject setObject:keychainName forType:kATKeychainType];
		[newObject setObject:(id)keychain forType:kATKeychainRefType];
		[newObject setObject:pathName forMeta:kQSObjectDetails];
		[newObject setObject:pathName forType:QSFilePathType];
		[newObject setPrimaryType:kATKeychainType];

		[objects addObject:newObject];
	}
	return objects;	
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry
{
	NSArray *foundKeychains = [self qsObjectsOfKeychains];
	if ([[theEntry objectForKey:@"name"] isEqualTo:@"Keychains"]) {
		return foundKeychains;
	}
	else if ([[theEntry objectForKey:@"name"] isEqualTo:@"Keychain Items"]) {
		NSMutableArray *keychainItems = [NSMutableArray arrayWithCapacity:1];
		NSEnumerator *e = [foundKeychains objectEnumerator];
		QSObject *q;
		while (q = [e nextObject]) {
			[keychainItems addObjectsFromArray:[self qsObjectsOfKeychainItems:(SecKeychainRef)[q objectForType:kATKeychainRefType]]];
		}
		return keychainItems;
	}
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return [@"[Keychain]:"stringByAppendingString:[object objectForType:kATKeychainType]];
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
	if ([object containsType:kATKeychainItemType]) { 
		[object setChildren:[self qsObjectsOfPropertiesOfKeychainItem:(SecKeychainItemRef)[object objectForType:kATKeychainItemRefType]]];
		return YES;
	}
	if ([object containsType:kATKeychainType]) {
		[object setChildren:[self qsObjectsOfKeychainItems:(SecKeychainRef)[object objectForType:kATKeychainRefType]]];
		return YES;
	}
	else {
		[object setChildren:[self qsObjectsOfKeychains]];
		return YES;   	
	}
}

- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"com.apple.keychainaccess"]];
}


@end

#define kATKeychainOpenAction @"ATKeychainOpenAction"
#define kATKeychainItemPasswordPasteAction @"ATKeychainItemPasswordPasteAction"
#define kATKeychainItemPasswordCopyAction @"ATKeychainItemPasswordCopyAction"
#define kATKeychainItemAccountPasteAction @"ATKeychainItemAccountPasteAction"
#define kATKeychainItemAccountCopyAction @"ATKeychainItemAccountCopyAction"
#define kATKeychainItemLocationCopyAction @"ATKeychainItemLocationCopyAction"
#define kATKeychainItemCommentCopyAction @"ATKeychainItemCommentCopyAction"

@implementation ATKeychainActionProvider

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject
						  indirectObject:(QSObject *)iObject
{
	if ([dObject containsType:kATKeychainItemType]) { 
		return [NSArray arrayWithObjects:kATKeychainItemPasswordCopyAction, nil];
	}
	else {
		return nil;
	}
}

- (void) copyFromObject:(QSObject *)dObject keychainField:(SecItemAttr)tag
{
	// obtain attributes from KeychainItem
	OSStatus status = 0;
	SecKeychainAttribute attributes[1];
	attributes[0].tag = tag;
	attributes[0].length = 0;
	
	SecKeychainAttributeList attrList = {1, attributes};
	
	status = SecKeychainItemCopyContent((SecKeychainItemRef)[dObject objectForType:kATKeychainItemRefType],
										NULL,
										&attrList,
										NULL, NULL); // for no password
	
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
											 owner:self];
	[[NSPasteboard generalPasteboard] setString:[NSString stringWithCString:(char *)attributes[0].data 
																	 length:attributes[0].length] 
										forType:NSStringPboardType];
}

- (QSObject *) copyComment:(QSObject *)dObject
{
	[self copyFromObject:dObject keychainField:kSecCommentItemAttr];
	return nil;

}

- (QSObject *) copyLocation:(QSObject *)dObject
{
	[self copyFromObject:dObject keychainField:kSecServiceItemAttr];
	return nil;
}


- (QSObject *) copyAccountName:(QSObject *)dObject
{
	[self copyFromObject:dObject keychainField:kSecAccountItemAttr];
	return nil;
}

- (QSObject *) copyPassword:(QSObject *)dObject
{
	SecKeychainItemRef itemRef = (SecKeychainItemRef)[dObject objectForType:kATKeychainItemRefType];

	if (itemRef) {
		UInt32 plen = 0;
		char *pword;
		OSStatus status;
		
		status = SecKeychainItemCopyContent(itemRef,
											NULL,
											NULL,
											&plen, 
											(void **)&pword);
		if (status) {
			return nil;
		}
		
		[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
												 owner:self];
		[[NSPasteboard generalPasteboard] setString:[NSString stringWithCString:pword length:plen] 
											forType:NSStringPboardType];
		
		SecKeychainItemFreeContent(NULL, pword);
		CFRelease(itemRef);
	}
	else {
		[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
												 owner:self];
		[[NSPasteboard generalPasteboard] setString:@"oops!"
											forType:NSStringPboardType];
	}
	
	return nil;
}

/*
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
	return YES;
}
*/

@end
