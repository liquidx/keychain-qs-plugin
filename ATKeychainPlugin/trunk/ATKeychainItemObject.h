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

- (id) initWithKeychainItemRef:(SecKeychainItemRef)newItemRef;

+ (BOOL) isValidKeychainItem:(SecKeychainItemRef)itemRef;
+ (ATKeychainItemObject *)keychainItemObject:(SecKeychainItemRef)newItemRef;
+ (NSDictionary *) internetKeychainItemToDictionary:(SecKeychainItemRef)itemRef;

@end
