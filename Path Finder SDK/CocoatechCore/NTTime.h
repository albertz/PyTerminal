//
//  NTTime.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/8/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sys/time.h>

@interface NTTime : NSObject {
	struct timeval mv_tv;
	struct timezone mv_tz;
}

+ (NTTime*)time;
+ (NTTime*)timeWithTimespec:(struct timespec*)ts;

// convert to NSDate
- (NSDate*)date;
- (struct timespec)timespec;

- (NSComparisonResult)compare:(NTTime *)right;
- (NSComparisonResult)compareSeconds:(NTTime *)right;  // less accurate compare

@end
