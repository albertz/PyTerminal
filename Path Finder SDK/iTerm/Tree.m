// -*- mode:objc -*-
// $Id: Tree.m,v 1.6 2006/11/16 07:42:45 yfabian Exp $
//
/*
 **  Tree.m
 **
 **  Copyright (c) 2002-2004
 **
 **  Author: Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: Implements a tree structure for bookmarks. 
 **				  Adapted from Apple's example code.
 **
 */

#import "Tree.h"

#define KEY_NAME			@"Name"
#define KEY_DESCRIPTION		@"Description"
#define KEY_IS_GROUP		@"Group Node"
#define KEY_ENTRIES			@"Entries"
#define KEY_DATA			@"Data"


@implementation NSArray (MyExtensions)

- (BOOL) containsObjectIdenticalTo: (id)obj { 
    return [self indexOfObjectIdenticalTo: obj]!=NSNotFound; 
}

@end

@implementation NSMutableArray (MyExtensions)

- (void)insertObjectsFromArray:(NSArray *)array atIndex:(NSInteger)index {
    NSObject *entry = nil;
    NSEnumerator *enumerator = [array objectEnumerator];
    while ((entry=[enumerator nextObject])) {
        [self insertObject:entry atIndex:index++];
    }
}

@end


@implementation TreeNode

+ (id)treeFromDictionary:(NSDictionary*)dict {
		
    return [[[TreeNode alloc] initFromDictionary:dict] autorelease];
}


- (id)initWithData:(NSDictionary *)data parent:(TreeNode*)parent children:(NSArray*)children {
    self = [super init];
    if (self==nil) return nil;
    
    nodeData = [[NSMutableDictionary alloc] initWithDictionary: data];
    nodeChildren = [[NSMutableArray arrayWithArray:children] retain];
    nodeParent = parent;
    
    return self;
}

- (id)initFromDictionary:(NSDictionary*)dict {
    // This is a convenience init method to return a tree root of a tree derived from an input dictionary.
    // The input dictionary for this example app is InitInfo.dict.  Look at that file to understand the format.
    NSDictionary *data = [dict objectForKey: KEY_DATA];
    NSEnumerator *entryEnum = [[dict objectForKey: KEY_ENTRIES] objectEnumerator];
    id entry;
    TreeNode *child = nil;
    
    self = [self initWithData:data parent:nil children:[NSArray array]];
    if (self==nil) return nil;
	
	if ([dict objectForKey: KEY_IS_GROUP])
		[self setIsLeaf: NO];
	else
		[self setIsLeaf: YES];
    
    while ((entry=[entryEnum nextObject])) 
	{
		// if child is another group, recursively add the branch
        if ([[entry objectForKey: KEY_IS_GROUP] isEqualToString: @"Yes"])
		{
            child = [TreeNode treeFromDictionary: entry];
		}
        else 
		{
			data = [entry objectForKey: KEY_DATA];
            child = [[[TreeNode alloc] initWithData: data parent:nil children: [NSArray array]] autorelease];
			[child setIsLeaf: YES];
		}
        [self insertChild: child atIndex: [self numberOfChildren]];
    }
    
    return self;
}

// return a dictionary representation of the node and its children
- (NSDictionary *) dictionary
{
	NSMutableDictionary *aDict;
	NSEnumerator *entryEnum;
	TreeNode *child;
	NSMutableArray *aMutableArray;
	
	aDict = [[NSMutableDictionary alloc] init];
	
	if (nodeData)
		[aDict setObject: nodeData forKey: KEY_DATA];
	if (!isLeaf)
		[aDict setObject: @"Yes" forKey: KEY_IS_GROUP];
	
	// recursively encode the children
	aMutableArray = [NSMutableArray array];
	entryEnum = [nodeChildren objectEnumerator];
	while ((child = [entryEnum nextObject]))
	{
		[aMutableArray addObject: [child dictionary]];
	}
	
	[aDict setObject: aMutableArray forKey: KEY_ENTRIES];
	
	return ([aDict autorelease]);
	
}

// return an array of all nodes
- (NSArray *) array
{
	NSEnumerator *entryEnum;
	TreeNode *child;
	NSMutableArray *aMutableArray;
	
	// recursively encode the children
	aMutableArray = [NSMutableArray array];
	entryEnum = [nodeChildren objectEnumerator];
	while ((child = [entryEnum nextObject]))
	{
		if ([child isLeaf])
			[aMutableArray addObject: child];
		else
			[aMutableArray addObjectsFromArray: [child array]];
	}
	
	return (aMutableArray);
	
}


- (void)dealloc {
    [nodeData release];
    [nodeChildren release];
    nodeData = nil;
    nodeChildren = nil;
    [super dealloc];
}

// ================================================================
// Methods used to manage a node and its children.
// ================================================================

- (void)setNodeData:(NSDictionary *)data { 
    [nodeData release]; 
    nodeData = [[NSMutableDictionary alloc] initWithDictionary: data]; 
}

- (NSDictionary *)nodeData { 
    return nodeData; 
}

- (void)setNodeParent:(TreeNode*)parent {
    nodeParent = parent; 
}

- (TreeNode*)nodeParent { 
    return nodeParent; 
}

- (BOOL)isGroup
{
	return (!isLeaf);
}

- (BOOL) isLeaf
{
	return (isLeaf);
}

- (void)setIsLeaf: (BOOL) flag
{
	isLeaf = flag;
}


- (void)insertChild:(TreeNode*)child atIndex:(NSInteger)index 
{
    [nodeChildren insertObject:child atIndex:index];
    [child setNodeParent: self];
}

- (void)insertChildren:(NSArray*)children atIndex:(NSInteger)index {
    [nodeChildren insertObjectsFromArray: children atIndex: index];
    [children makeObjectsPerformSelector:@selector(setNodeParent:) withObject:self];
}

- (void)_removeChildrenIdenticalTo:(NSArray*)children {
    TreeNode *child;
    NSEnumerator *childEnumerator = [children objectEnumerator];
    [children makeObjectsPerformSelector:@selector(setNodeParent:) withObject:nil];
    while ((child=[childEnumerator nextObject])) {
        [nodeChildren removeObjectIdenticalTo:child];
    }
}

- (void)removeChild:(TreeNode*)child {
    NSInteger index = [self indexOfChild: child];
    if (index!=NSNotFound) {
        [self _removeChildrenIdenticalTo: [NSArray arrayWithObject: [self childAtIndex:index]]];
    }
}

- (void)removeFromParent {
    [[self nodeParent] removeChild:self];
}

- (NSInteger)indexOfChild:(TreeNode*)child {
    return [nodeChildren indexOfObject:child];
}

- (NSInteger)indexOfChildIdenticalTo:(TreeNode*)child {
    return [nodeChildren indexOfObjectIdenticalTo:child];
}

- (NSInteger)numberOfChildren {
    return [nodeChildren count];
}

- (NSArray*)children {
    return [NSArray arrayWithArray: nodeChildren];
}

- (TreeNode*)firstChild {
    return [nodeChildren objectAtIndex:0];
}

- (TreeNode*)lastChild {
    return [nodeChildren lastObject];
}

- (TreeNode*)childAtIndex:(NSInteger)index {
    return [nodeChildren objectAtIndex:index];
}

- (BOOL)isDescendantOfNode:(TreeNode*)node {
    // returns YES if 'node' is an ancestor.
    // Walk up the tree, to see if any of our ancestors is 'node'.
    TreeNode *parent = self;
    while(parent) {
        if (parent==node) return YES;
        parent = [parent nodeParent];
    }
    return NO;
}

- (BOOL)isDescendantOfNodeInArray:(NSArray*)nodes {
    // returns YES if any 'node' in the array 'nodes' is an ancestor of ours.
    // For each node in nodes, if node is an ancestor return YES.  If none is an
    // ancestor, return NO.
    NSEnumerator *nodeEnum = [nodes objectEnumerator];
    TreeNode *node = nil;
    while((node=[nodeEnum nextObject])) {
        if ([self isDescendantOfNode:node]) return YES;
    }
    return NO;
}

- (void)recursiveSortChildren {
    [nodeChildren sortUsingSelector:@selector(compare:)];
    [nodeChildren makeObjectsPerformSelector: @selector(recursiveSortChildren)];
}

- (NSInteger) indexForNode:(id)node {
	return ([[self array] indexOfObject:node]);
}

- (id)nodeForIndex: (NSInteger) index {
	return ([[self array] safeObjectAtIndex:index]);
}

- (NSString*)description {
    // Return something that will be useful for debugging.
    return [NSString stringWithFormat: @"{%@}", nodeData];
}

// Returns the minimum nodes from 'allNodes' required to cover the nodes in 'allNodes'.
// This methods returns an array containing nodes from 'allNodes' such that no node in
// the returned array has an ancestor in the returned array.

// There are better ways to compute this, but this implementation should be efficient for our app.
+ (NSArray *) minimumNodeCoverFromNodesInArray: (NSArray *)allNodes {
    NSMutableArray *minimumCover = [NSMutableArray array];
    NSMutableArray *nodeQueue = [NSMutableArray arrayWithArray:allNodes];
    TreeNode *node = nil;
    while ([nodeQueue count]) {
        node = [nodeQueue objectAtIndex:0];
        [nodeQueue removeObjectAtIndex:0];
        while ( [node nodeParent] && [nodeQueue containsObjectIdenticalTo:[node nodeParent]] ) {
            [nodeQueue removeObjectIdenticalTo: node];
            node = [node nodeParent];
        }
        if (![node isDescendantOfNodeInArray: minimumCover]) [minimumCover addObject: node];
        [nodeQueue removeObjectIdenticalTo: node];
    }
    return minimumCover;
}

- (id)initWithCoder:(NSCoder *)coder { 
	self = 	[[TreeNode alloc] initFromDictionary:[coder decodeObject]]; 
	return self; 
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	if (self) { 
		[coder encodeObject: [self dictionary]]; 
	} 
}

@end
