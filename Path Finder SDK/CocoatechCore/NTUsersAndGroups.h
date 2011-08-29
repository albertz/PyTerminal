//
//  NTUsersAndGroups.h
//  CocoatechCore
//
//  Created by sgehrman on Tue Jul 31 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTSingletonObject.h"

@class NTNameAndID;

@interface NTUsersAndGroups : NTSingletonObject
{
    BOOL mIsRoot;
    NSString* mUserName;
    UInt32 mUserID;
    UInt32 mGroupID;
    NSArray* mUserGroups;
    NSArray* mUsers;
    NSArray* mGroups;
}

- (BOOL)isRoot;
- (NSString *)userName;

- (UInt32)userID;
- (UInt32)groupID;
- (NSArray *)userGroups;
- (NSArray *)users;
- (NSArray *)groups;

- (NTNameAndID*)userWithID:(int)userID;
- (NTNameAndID*)groupWithID:(int)groupID;

- (BOOL)userIsMemberOfGroup:(int)groupID;

- (NSString*)groupName:(int)groupID;
- (NSString*)userName:(int)userID;

- (int)groupID:(NSString*)groupName;
- (int)userID:(NSString*)userName;

// menuItem tag has the group and user IDs
- (NSMenu*)userMenu:(NSString*)filterPrefix;
- (NSMenu*)groupMenu:(NSString*)filterPrefix;

// append to existing menu
- (void)userMenu:(NSMenu*)menu target:(id)target action:(SEL)action filterPrefix:(NSString*)filterPrefix;
- (void)groupMenu:(NSMenu*)menu target:(id)target action:(SEL)action filterPrefix:(NSString*)filterPrefix;

@end
