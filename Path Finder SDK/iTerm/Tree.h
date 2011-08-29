// -*- mode:objc -*-
// $Id: Tree.h,v 1.3 2006/10/20 05:40:08 yfabian Exp $
//
/*
 **  Tree.h
 **
 **  Copyright (c) 2002-2004
 **
 **  Author: Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: Headertree structure for bookmarks. 
 **				  Adapted from Apple's example code.
 **
 */

#import <Foundation/Foundation.h>

@interface NSArray (MyExtensions)
- (BOOL)containsObjectIdenticalTo: (id)object;
@end

@interface NSMutableArray (MyExtensions)
- (void)insertObjectsFromArray:(NSArray *)array atIndex:(NSInteger)index;
@end


@interface TreeNode : NSObject 
{
    TreeNode *nodeParent;
	BOOL isLeaf;
	NSMutableArray *nodeChildren;
    NSMutableDictionary *nodeData;
}
+ (id)treeFromDictionary:(NSDictionary*)dict;
- (id)initWithData:(NSDictionary *)data parent:(TreeNode*)parent children:(NSArray*)children;
- (id)initFromDictionary:(NSDictionary*)dict;
- (NSDictionary *) dictionary;

- (void)setNodeData:(NSDictionary *)data;
- (NSDictionary *) nodeData;

- (void)setNodeParent:(TreeNode*)parent;
- (TreeNode*)nodeParent;

- (BOOL) isLeaf;
- (void)setIsLeaf: (BOOL) flag;
- (BOOL)isGroup;

- (void)insertChild:(TreeNode*)child atIndex:(NSInteger)index;
- (void)insertChildren:(NSArray*)children atIndex:(NSInteger)index;
- (void)removeChild:(TreeNode*)child;
- (void)removeFromParent;

- (NSInteger)indexOfChild:(TreeNode*)child;
- (NSInteger)indexOfChildIdenticalTo:(TreeNode*)child;

- (NSInteger)numberOfChildren;
- (NSArray*)children;
- (TreeNode*)firstChild;
- (TreeNode*)lastChild;
- (TreeNode*)childAtIndex:(NSInteger)index;

- (BOOL)isDescendantOfNode:(TreeNode*)node;
    // returns YES if 'node' is an ancestor.

- (BOOL)isDescendantOfNodeInArray:(NSArray*)nodes;
    // returns YES if any 'node' in the array 'nodes' is an ancestor of ours.

- (void)recursiveSortChildren;
    // sort children using the compare: method in TreeNodeData

- (NSInteger) indexForNode:(id)node;
- (id)nodeForIndex: (NSInteger) index;

	// Returns the minimum nodes from 'allNodes' required to cover the nodes in 'allNodes'.
	// This methods returns an array containing nodes from 'allNodes' such that no node in
	// the returned array has an ancestor in the returned array.
+ (NSArray *)minimumNodeCoverFromNodesInArray: (NSArray *)allNodes;

@end
