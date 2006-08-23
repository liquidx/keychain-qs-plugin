//
//  ATKeychainPlugin.h
//  ATKeychainPlugin
//
//  Created by Alastair on 22/08/2006.
//  Copyright liquidx.net 2006. All rights reserved.
//

#import "ATKeychain.h"
#import "ATKeychainItemObject.h"

@interface ATKeychainPlugin : NSObject
{
}
+ (NSArray *)allKeychains;
+ (NSArray *)allKeychainItemsAsQSObjects;
+ (NSDate *) mostRecentKeychainUpdate;
@end

