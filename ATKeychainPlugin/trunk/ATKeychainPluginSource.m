//
//  ATKeychainPluginSource.m
//  ATKeychainPlugin
//
//  Created by Alastair on 22/08/2006.
//  Copyright liquidx.net 2006. All rights reserved.
//

#import "ATKeychainPluginSource.h"
#import <QSCore/QSObject.h>


@implementation ATKeychainPluginSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}


// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	newObject=[QSObject objectWithName:@"TestObject"];
	[newObject setObject:@"" forType:ATKeychainPluginType];
	[newObject setPrimaryType:ATKeychainPluginType];
	[objects addObject:newObject];
  
    return objects;
    
}


// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:nil]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:kATKeychainPluginType];
	[object setIcon:nil];
    return YES;
}
*/
@end
