//
//  ATKeychainItemObject.m
//  ATKeychainPlugin
//
//  Created by Alastair on 22/08/2006.
//  Copyright 2006 liquidx.net. All rights reserved.
//

#import "ATKeychainItemObject.h"

// TODO: support archiving and referring using identifier

@implementation ATKeychainItemObject

- (id) initWithKeychainItemRef:(SecKeychainItemRef)newItemRef
{
	self = [super init];
	if (self) {
		children = nil;
		
		if (!newItemRef) {
			keychainProperties = nil;
		}
		else {
			CFRetain(newItemRef);
			keychainProperties = [[ATKeychainItemObject internetKeychainItemToDictionary:newItemRef] retain];
			
			// Setup other QSObject attributes
			[self setName:[keychainProperties objectForKey:@"Name"]];
			[self setDetails:[keychainProperties objectForKey:@"Account"]];
			[self setObject:[keychainProperties objectForKey:@"Name"] 
					forType:QSTextType];
			[self setObject:(id)newItemRef forType:kATKeychainItemType];
			[self setObject:kATKeychainItemPasswordCopyAction forMeta:kQSObjectDefaultAction];
			[self setPrimaryType:kATKeychainItemType];
			
			// create identifier
			NSString *keychain = [keychainProperties objectForKey:@"Keychain"];
			[self setIdentifier:[NSString stringWithFormat:@"keychain://%@/%@", 
				keychain, [keychainProperties objectForKey:@"Name"]]];
		}
	}
	return self;
}

- (void) dealloc
{
	SecKeychainItemRef itemRef = (SecKeychainItemRef)[self objectForType:kATKeychainItemType];
	if (itemRef) {
		CFRelease(itemRef);
		[self setObject:nil forType:kATKeychainItemType];
	}
	if (children)
		[children release];
	if (keychainProperties)
		[keychainProperties release];
	[super dealloc];
}

+ (ATKeychainItemObject *)keychainItemObject:(SecKeychainItemRef)newItemRef
{
	return [[[ATKeychainItemObject alloc] initWithKeychainItemRef:newItemRef] autorelease];
}	

+ (BOOL) isValidKeychainItem:(SecKeychainItemRef)itemRef
{
	// do some basic checks to see whether we should index this item in QS.
	OSStatus status;
	SecKeychainAttribute attributes[2];
	attributes[0].tag = kSecNegativeItemAttr;
	attributes[1].tag = kSecServiceItemAttr;
	SecKeychainAttributeList attrList = {2, attributes};
	BOOL isValid = NO;
	
	status = SecKeychainItemCopyContent(itemRef, NULL, &attrList, NULL, NULL);
	if (status != noErr)
		return NO;
	
	//NSLog(@"ATKeychain: %s", attributes[1].data);
	if (!attributes[0].data)		
		isValid = YES;
	
	SecKeychainItemFreeContent(&attrList, NULL);
	
	return isValid;
}
	

+ (NSDictionary *) internetKeychainItemToDictionary:(SecKeychainItemRef)anItemRef
{
	NSMutableDictionary *item;
	OSStatus status;
	int i = 0;
	
	NSString *keys[5] = {
		@"Name",
		@"Account",
		@"Description",
		@"Comment",
		@"Date"
	};
	
	// obtain attributes from KeychainItem
	SecKeychainAttribute attributes[5];
	attributes[0].tag = kSecLabelItemAttr;
	attributes[1].tag = kSecAccountItemAttr;
	attributes[2].tag = kSecDescriptionItemAttr;
	attributes[3].tag = kSecCommentItemAttr;
	attributes[4].tag = kSecModDateItemAttr;
	
	SecKeychainAttributeList attrList = {5, attributes};
	
	status = SecKeychainItemCopyContent(anItemRef,
										NULL,
										&attrList,
										NULL, NULL); // for no password
	
	if (status != noErr) {
		return nil;
	}
	
	item = [NSMutableDictionary dictionary];
	for (i = 0; i < attrList.count; i++) {
		if (attributes[i].tag == kSecModDateItemAttr) {
			UInt32 moddate = (UInt32)attributes[i].data;
			[item setValue:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)moddate]
					forKey:keys[i]];
			
		}
		else if (attributes[i].length > 0) {
			[item setValue:[NSString stringWithCString:attributes[i].data
												length:attributes[i].length]
					forKey:keys[i]];
		}
	}
	SecKeychainItemFreeContent(&attrList, NULL);
	
	// get keychain details as well
	SecKeychainRef keychainRef;
	status = SecKeychainItemCopyKeychain(anItemRef, &keychainRef);
	if (status == noErr) {
		UInt32 pathLen = 1024;
		char path[1024];
		NSString *pathString;
		status = SecKeychainGetPath(keychainRef, &pathLen, path);
		if (status == noErr) {
			[item setObject:[NSString stringWithCString:path length:pathLen]
					 forKey:@"Keychain"];
		}
		CFRelease(keychainRef);
	}
	
	return item;
}

#pragma mark -

// QSObject 
- (NSArray *)children
{
	if ((children == nil) && (keychainProperties != nil)) {
		// construct a set of QSObjects that refer correspond to 
		// a property, and then set their kATKeychainItemObjectType
		NSMutableArray *newChildren = [NSMutableArray array];
		NSArray *fields = [NSArray arrayWithObjects:
			@"Name", 
			@"Account", 
			@"Description", 
			@"Comment",
			nil];
		NSEnumerator *e = [fields objectEnumerator];
		NSString *key = nil;
		while (key = [e nextObject]) {
			NSString *value = [keychainProperties objectForKey:key];
			if (value) {
				QSObject *propertyObject = [QSObject objectWithName:key];
				[propertyObject setDetails:value];
				[propertyObject setPrimaryType:kATKeychainPropertyType];
				[propertyObject setObject:value forType:QSTextType];
				[propertyObject setObject:self forType:kATKeychainItemType];
				[newChildren addObject:propertyObject];
			}
		}
		
		children = [newChildren retain];
	}
	return children;
}
@end


