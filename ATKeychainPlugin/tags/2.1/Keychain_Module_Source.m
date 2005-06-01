//
//  Keychain_Module_Source.m
//  Keychain Module
//
//  Created by Alastair on 27/03/2005.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "Keychain_Module_Source.h"
#import <QSCore/QSObject.h>


@implementation Keychain_Module_Source
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	newObject=[QSObject objectWithName:@"TestObject"];
	[newObject setObject:@"" forType:Keychain_ModuleType];
	[newObject setPrimaryType:Keychain_ModuleType];
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
    id data=[object objectForType:Keychain_ModuleType];
	[object setIcon:nil];
    return YES;
}
*/
@end
