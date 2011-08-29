//
//  NTUsersAndGroups.m
//  CocoatechCore
//
//  Created by sgehrman on Tue Jul 31 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTUsersAndGroups.h"
#import <grp.h>
#import <pwd.h>
#include <unistd.h>
#import <DirectoryService/DirectoryService.h>
#import "NTNameAndID.h"
#import "NSMenuItem-NTExtensions.h"
#import "NSMenu-NTExtensions.h"

@interface NTUsersAndGroups (hidden)
- (void)setIsRoot:(BOOL)flag;
- (void)setUserName:(NSString *)theUserName;
- (void)setUserID:(UInt32)theUserID;
- (void)setGroupID:(UInt32)theGroupID;
- (void)setUserGroups:(NSArray *)theUserGroups;
- (void)setUsers:(NSArray *)theUsers;
- (void)setGroups:(NSArray *)theGroups;
@end

@interface NTUsersAndGroups (Private)
- (NSArray*)buildUserList;
- (NSArray*)buildGroupList;
- (NSArray*)buildUserGroupsList;
@end

@implementation NTUsersAndGroups

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

- (id)init;
{
    self = [super init];

    [self setUserID:getuid()];
    [self setGroupID:getgid()];
    [self setUserName:NSUserName()];
	[self setIsRoot:([self userID] == 0)];
	
    return self;
}

- (void)dealloc
{
    [self setUserName:nil];
    [self setUserGroups:nil];
    [self setUsers:nil];
    [self setGroups:nil];
	
    [super dealloc];
}

//---------------------------------------------------------- 
//  isRoot 
//---------------------------------------------------------- 
- (BOOL)isRoot
{
    return mIsRoot;
}

- (void)setIsRoot:(BOOL)flag
{
    mIsRoot = flag;
}

//---------------------------------------------------------- 
//  userName 
//---------------------------------------------------------- 
- (NSString *)userName
{
    return mUserName; 
}

- (void)setUserName:(NSString *)theUserName
{
    if (mUserName != theUserName) {
        [mUserName release];
        mUserName = [theUserName retain];
    }
}

//---------------------------------------------------------- 
//  userID 
//---------------------------------------------------------- 
- (UInt32)userID
{
    return mUserID;
}

- (void)setUserID:(UInt32)theUserID
{
    mUserID = theUserID;
}

//---------------------------------------------------------- 
//  groupID 
//---------------------------------------------------------- 
- (UInt32)groupID
{
    return mGroupID;
}

- (void)setGroupID:(UInt32)theGroupID
{
    mGroupID = theGroupID;
}

//---------------------------------------------------------- 
//  userGroups 
//---------------------------------------------------------- 
- (NSArray *)userGroups
{
	@synchronized(self) {
		if (!mUserGroups)
			[self setUserGroups:[self buildUserGroupsList]];
	}
	
    return mUserGroups; 
}

- (void)setUserGroups:(NSArray *)theUserGroups
{
    if (mUserGroups != theUserGroups) {
        [mUserGroups release];
        mUserGroups = [theUserGroups retain];
    }
}

//---------------------------------------------------------- 
//  users 
//---------------------------------------------------------- 
- (NSArray *)users
{
	@synchronized(self) {
		if (!mUsers)
			[self setUsers:[self buildUserList]];
	}
	
    return mUsers; 
}

- (void)setUsers:(NSArray *)theUsers
{
    if (mUsers != theUsers) {
        [mUsers release];
        mUsers = [theUsers retain];
    }
}

//---------------------------------------------------------- 
//  groups 
//---------------------------------------------------------- 
- (NSArray *)groups
{
	@synchronized(self) {
		if (!mGroups)
			[self setGroups:[self buildGroupList]];
	}
	
    return mGroups; 
}

- (void)setGroups:(NSArray *)theGroups
{
    if (mGroups != theGroups) {
        [mGroups release];
        mGroups = [theGroups retain];
    }
}

- (BOOL)userIsMemberOfGroup:(int)groupID;
{
	// unknown group
	if (groupID == 99)
		return YES;
	
	NSArray* ug = [self userGroups];
    NTNameAndID *nameAndID;

	for (nameAndID in ug)
    {

        if (groupID == [nameAndID identifier])
            return YES;
    }

    return NO;
}

- (NSString*)groupName:(int)groupID;
{
	NTNameAndID* obj = [self groupWithID:groupID];
	
	if (obj)
		return [obj name];
	
    return @"";
}

- (NSString*)userName:(int)userID;
{
	NTNameAndID* obj = [self userWithID:userID];
	
	if (obj)
		return [obj name];
	
    return @"";
}

- (int)groupID:(NSString*)groupName;
{
    NSArray* groups = [self groups];
    NTNameAndID *obj;

    for (obj in groups)
    {

        if ([[obj name] isEqualToString:groupName])
            return [obj identifier];
    }

    return -1;
}

- (int)userID:(NSString*)userName;
{
    NSArray* users = [self users];

    for (NTNameAndID *obj in users)
    {

        if ([[obj name] isEqualToString:userName])
            return [obj identifier];
    }

    return -1;
}

- (NSMenu*)groupMenu:(NSString*)filterPrefix;
{
	NSMenu* menu = [[[NSMenu alloc] init] autorelease];

	[self groupMenu:menu target:nil action:0 filterPrefix:filterPrefix];
	
	return menu;
}

- (void)groupMenu:(NSMenu*)menu target:(id)target action:(SEL)action filterPrefix:(NSString*)filterPrefix;
{    
    NSArray* grpList = [self groups];
    NSMenuItem* menuItem;
    
    for (NTNameAndID* item in grpList)
    {
		if (filterPrefix && [[item name] hasPrefix:filterPrefix])
			continue;

        menuItem = [[[NSMenuItem alloc] initWithTitle:[item name] action:action keyEquivalent:@""] autorelease];
        [menuItem setTarget:target];
        [menuItem setTag:[item identifier]];
		[menuItem setFontSize:kSmallMenuFontSize color:nil];
		
		NSAttributedString* numString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%d)", [item identifier]] attributes:[NSMenu infoAttributes:kSmallMenuFontSize]] autorelease];
		NSMutableAttributedString* attributedTitle = [[[NSMutableAttributedString alloc] initWithAttributedString:[menuItem attributedTitle]] autorelease];
		
		[attributedTitle appendAttributedString:numString];
		[menuItem setAttributedTitle:attributedTitle];
		
        [menu addItem:menuItem];
    }
}

- (NSMenu*)userMenu:(NSString*)filterPrefix;
{
	NSMenu* menu = [[[NSMenu alloc] init] autorelease];

	[self userMenu:menu target:nil action:0 filterPrefix:filterPrefix];
	
	return menu;
}

- (void)userMenu:(NSMenu*)menu target:(id)target action:(SEL)action filterPrefix:(NSString*)filterPrefix;
{
    NSArray* userList = [self users];
    NSMenuItem* menuItem;
    
    for (NTNameAndID* item in userList)
    {
		if (filterPrefix && [[item name] hasPrefix:filterPrefix])
			continue;
		
        menuItem = [[[NSMenuItem alloc] initWithTitle:[item name] action:action keyEquivalent:@""] autorelease];
        [menuItem setTarget:target];
        [menuItem setTag:[item identifier]];
        [menuItem setFontSize:kSmallMenuFontSize color:nil];

		NSAttributedString* numString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%d)", [item identifier]] attributes:[NSMenu infoAttributes:kSmallMenuFontSize]] autorelease];
		NSMutableAttributedString* attributedTitle = [[[NSMutableAttributedString alloc] initWithAttributedString:[menuItem attributedTitle]] autorelease];
		
		[attributedTitle appendAttributedString:numString];
		[menuItem setAttributedTitle:attributedTitle];
		
        [menu addItem:menuItem];
    }
}

- (NTNameAndID*)userWithID:(int)userID;
{
	NSEnumerator* enumerator = [[self users] objectEnumerator];
    NTNameAndID *obj;
	
	while (obj = [enumerator nextObject])
    {
        if ([obj identifier] == userID)
            return obj;
    }
	
    return nil;
}

- (NTNameAndID*)groupWithID:(int)groupID;
{
	NSEnumerator* enumerator = [[self groups] objectEnumerator];
    NTNameAndID *obj;
	
	while (obj = [enumerator nextObject])
    {
        if ([obj identifier] == groupID)
            return obj;
    }
	
    return nil;	
}

@end

@implementation NTUsersAndGroups (Private)

- (NSArray*)buildUserGroupsList;
{
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:5];
	
	gid_t groups[NGROUPS_MAX];
	int ngroups = getgroups(NGROUPS_MAX, groups);
	gid_t gid;
	struct group *grp;
	
	while (--ngroups >= 0)
	{
		gid = groups[ngroups];
		
		grp = getgrgid(gid);
		
		if (grp)
			[result addObject:[NTNameAndID nameAndID:[NSString stringWithUTF8String:grp->gr_name] identifier:gid]];
	}
	
    // sort the list
    [result sortUsingSelector:@selector(compare:)];
		
    return result;
}

- (NSArray*)buildGroupList
{
    struct group* grp;
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:100];
	
    setgrent();
	
    do
    {
        grp = getgrent();
		
        if (grp)
		{
			if (strlen(grp->gr_name))
				[result addObject:[NTNameAndID nameAndID:[NSString stringWithUTF8String:grp->gr_name] identifier:grp->gr_gid]];
		}
    } while (grp);
	
    endgrent();
	
    // sort the list
    [result sortUsingSelector:@selector(compare:)];
	
    return result;
}

- (NSArray*)buildUserList
{
    struct passwd* pw;
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:100];
	
    setpwent();
	
    do
    {
        pw = getpwent();
		
        if (pw)
		{
			if (strlen(pw->pw_name))
				[result addObject:[NTNameAndID nameAndID:[NSString stringWithUTF8String:pw->pw_name] identifier:pw->pw_uid]];
		}
		
    } while (pw);
	
    endpwent();
	
    // sort the list
    [result sortUsingSelector:@selector(compare:)];
    
    return result;
}

@end

