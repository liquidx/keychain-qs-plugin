//
//  ATKeychainObjectHandler.m
//  ATKeychainPlugin
//
//  Created by Alastair on 22/08/2006.
//  Copyright 2006 liquidx.net. All rights reserved.
//

#import "ATKeychainObjectHandler.h"


@implementation ATKeychainObjectHandler

- (BOOL)objectHasChildren:(QSObject *)object
{
	if ([[object primaryType] isEqualToString:kATKeychainItemType])
		return YES;
	return NO;
}

- (NSArray *)childrenForObject:(QSObject *)object
{
	if ([[object primaryType] isEqualToString:kATKeychainItemType])
		return [object children];
	return nil;
}

- (QSObject *)parentOfObject:(QSObject *)object
{
	//NSLog(@"parentOfObject: %@ of type %@", object, [object primaryType]);
	
	if ([[object primaryType] isEqualToString:kATKeychainPropertyType]) {
		QSObject *parent = [object objectForType:kATKeychainItemType];
		//NSLog(@"parentOfObject: %@ -> %@", object, parent);
		return parent;
	}
	return nil;
}

- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"com.apple.keychainaccess"]];
}


- (BOOL)loadIconForObject:(QSObject *)object
{
	return NO;
}


@end
