//
//  INTFormatter.h
//  DockSpaces
//
//  Created by Patrick Chamelo on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MRGAppDelegate;

@interface INTFormatter : NSFormatter {
	MRGAppDelegate *appDelegate;
}

@property (strong) IBOutlet MRGAppDelegate *appDelegate;

@end
