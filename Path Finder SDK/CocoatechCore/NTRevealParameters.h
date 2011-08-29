//
//  NTRevealParameters.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTRevealParameters : NSObject {
	BOOL mTreatPackagesAsFolders;
	NSDictionary* mOther;
}

+ (NTRevealParameters*)params:(BOOL)treatPackagesAsFolders other:(NSDictionary*)other;

- (BOOL)treatPackagesAsFolders;
- (NSDictionary *)other;

@end
