//
//  MRGAppDelegate.m
//  PandaRefUid
//
//  Created by Вадим Бабаджанян on 9/8/11.
//  Copyright (c) 2011 "АйТи Территория". All rights reserved.
//

#import "MRGAppDelegate.h"

@implementation MRGAppDelegate

@synthesize window = _window, statusMenu, myMenuStatusItem,dateCell,unixTimeStampCell,fullDate,intCell1,intCell2,calculatorResultCell,calculatorResultCell2;

- (void)dealloc {
	[_window release];
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	opTag = 1;
	calculatorResultCell.title = @"";
	calculatorResultCell2.title = @"";
	
	// Insert code here to initialize your application
	[_window setDelegate:self];
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:[NSImage imageNamed:@"Icon.png"]];
	[statusItem setHighlightMode:YES];
	
	[[NSApplication sharedApplication] stopModal];
	
	
	
	[self ChangeTime:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]]];
	unixTimeStampCell.title = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
	
}

-(IBAction)NowDate:(id)sender {
	[self ChangeTime:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]]];
	unixTimeStampCell.title = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];

}


-(void)ChangeTime:(NSString *)unixTime {
	NSDate *d = [NSDate dateWithTimeIntervalSince1970:[unixTime intValue]];
	NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
	
	// Thursday, January 1, 1970 3:00:00 AM GMT+03:00
	
	[inFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *dateString = [inFormat stringFromDate:d];
	
	dateCell.title = dateString;
	fullDate.title = MRDate(@"EEEE, MMMM d, yyyy H:mm:ss z VVVV", (int)[d timeIntervalSince1970]);
	
	NSLog(@"%@ -> %d",dateString,(int)[d timeIntervalSince1970]);
	
}


-(IBAction)ChangeDate:(id)sender {
	NSLog(@"%@",[[sender cell] title]);
	NSString *date = [NSString stringWithString:[[sender cell] title]];
	NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
	[inFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *parsed = [inFormat dateFromString:date];
	NSString *dateString = [inFormat stringFromDate:parsed];
	
	NSLog(@"%@ -> %d",dateString,(int)[parsed timeIntervalSince1970]);
	
	if (dateString == nil) {
		[self ChangeTime:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]]];
		unixTimeStampCell.title = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
	} else {
		dateCell.title = [NSString stringWithFormat:@"%@",dateString];
		fullDate.title = MRDate(@"EEEE, MMMM d, yyyy H:mm:ss z VVVV", (int)[parsed timeIntervalSince1970]);
		unixTimeStampCell.title = [NSString stringWithFormat:@"%d",(int)[parsed timeIntervalSince1970]];
	}
}

-(IBAction)ChangeCalcOp:(id)sender {
	NSLog(@"%@",[sender description]);
	
	for (int i=0; i<4; i++) {
		if ([(NSSegmentedControl *)sender isSelectedForSegment:i]) {
			opTag = i;
			break;
		}
	}
	
	[self Calculate:nil];
	
}

-(IBAction)Calculate:(id)sender {
	NSLog(@"%@",intCell1.title);
	NSLog(@"%@",intCell2.title);
	
	calculatorResultCell.title = @"";
	calculatorResultCell2.title = @"";
	
	if (opTag == 2 && [intCell2.title intValue] == 0) return;
	
	switch (opTag) {
		case 0:
			calculatorResultCell.title = [NSString stringWithFormat:@"%d",([intCell1.title intValue]+[intCell2.title intValue])];
			break;
		case 1:
			calculatorResultCell.title = [NSString stringWithFormat:@"%d",([intCell1.title intValue]-[intCell2.title intValue])];
			break;
		case 2:
			calculatorResultCell.title = [NSString stringWithFormat:@"%d",([intCell1.title intValue]/[intCell2.title intValue])];
			break;
		case 3:
			calculatorResultCell.title = [NSString stringWithFormat:@"%d",([intCell1.title intValue]*[intCell2.title intValue])];
			break;
		default:
			break;
	}
	
	NSMutableString *newString = [NSMutableString stringWithCapacity:100];
	
	int y = 0;
	int M = 0;
	int d = 0;
	int h = 0;
	int m = 0;
	int s = 0;
	
	int sec = [calculatorResultCell.title intValue];
	
	
	if (sec >= 31104000) { 
		y = (int)(sec/31104000);
		sec-= y*31104000;
		[newString appendFormat:@"%d y ",y];
	}
	
	if (sec >= 2592000) { 
		M = (int)(sec/2592000);
		sec-= M*2592000;
		[newString appendFormat:@"%d m ",M];
	}
	
	if (sec >= 86400) { 
		d = (int)(sec/86400);
		sec-= d*86400;
		[newString appendFormat:@"%d d ",d];
	}	
	
	if (sec >= 3600) { 
		h = (int)(sec/3600);
		sec-= h*3600;
		[newString appendFormat:@"%d h ",h];
	}
	
	if (sec > 60) { 
		m = (int)(sec/60);
		sec-= m*60;
		[newString appendFormat:@"%d min ",m];
	}
	
	s = sec;
	if (s > 0) [newString appendFormat:@"%d sec ",s];
	
	calculatorResultCell2.title = newString;
	
}



- (void)windowWillClose:(NSNotification *)aNotification {
	
}

- (BOOL)windowShouldClose:(id)sender {
	[[NSApplication sharedApplication] hide:self];
	return NO;
}

-(IBAction) applicationUnHide:(id)sender {
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[NSApplication sharedApplication] unhide:self];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
	[[NSApplication sharedApplication] unhide:self];
	return YES;
}




@end
