//
//  INTFormatter.m
//  DockSpaces
//
//  Created by Patrick Chamelo on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "INTFormatter.h"
#import "MRGAppDelegate.h"

@implementation INTFormatter

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
	
    return(YES);
}

@end
