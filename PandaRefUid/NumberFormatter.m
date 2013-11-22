//
//  NumberFormatter.m
//  DockSpaces
//
//  Created by Patrick Chamelo on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NumberFormatter.h"
#import "MRGAppDelegate.h"

@implementation NumberFormatter

@synthesize appDelegate;

- (NSString *)stringForObjectValue:(id)string {
		return(string);
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error {
    *obj = string;
    return(YES);
}


- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString**)error {
	NSRange foundRange;
	
	NSCharacterSet *disallowedCharacters = [[NSCharacterSet
							characterSetWithCharactersInString:@"0123456789"] invertedSet];
	foundRange = [partialString rangeOfCharacterFromSet:disallowedCharacters];
	if(foundRange.location != NSNotFound) {
        NSBeep();
        return(NO);
	}
	
	NSDate *d = [NSDate dateWithTimeIntervalSince1970:[partialString intValue]];

	newString[0] = [NSString stringWithFormat:@"%d",(int)[d timeIntervalSince1970]];
	
	NSLog(@"TIME = %@",partialString);
	
	[appDelegate ChangeTime:partialString];
	
    return(NO);
}

@end
