//
//  ATKeychainItemObject.h
//  ATKeychainPlugin
//
//  Created by Alastair on 22/08/2006.
//  Copyright 2006 liquidx.net. All rights reserved.
//

#import "ATKeychain.h"

@interface ATKeychainItemObject : QSObject {
	NSArray				*children;
	NSDictionary		*keychainProperties;
}

- (id) initWithKeychainItemRef:(SecKeychainItemRef)newItemRef
					 itemClass:(SecItemClass)itemClass;
+ (BOOL) isValidKeychainItem:(SecKeychainItemRef)itemRef 
				   itemClass:(SecItemClass)itemClass;
+ (ATKeychainItemObject *)keychainItemObject:(SecKeychainItemRef)newItemRef 
								   itemClass:(SecItemClass)itemClass;

+ (NSDictionary *) internetKeychainItemToDictionary:(SecKeychainItemRef)itemRef;

@end
