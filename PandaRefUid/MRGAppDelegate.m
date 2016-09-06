//
//  MRGAppDelegate.m
//  PandaRefUid
//
//  Created by Вадим Бабаджанян on 9/8/11.
//  Copyright (c) 2011 "АйТи Территория". All rights reserved.
//

#import "MRGAppDelegate.h"
#import "TSTapstream.h"


@implementation MRGAppDelegate

@synthesize window = _window, statusMenu, myMenuStatusItem,dateCell,unixTimeStampCell, fullDate, intCell1, Start_Date, End_Date, End_Time, End_Date2, End_Time2, Start_Time,intCell2,calculatorResultCell,calculatorResultCell2,HideFromDock;

- (void)dealloc {
	[_window release];
    [super dealloc];
}

- (IBAction)hideFromDock:(id)sender {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (sender == nil) {
		if ([userDefaults boolForKey:@"HideFromDock"]) {
			[NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
			HideFromDock.title = @"Show in Dock";
		} else {
			[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
			HideFromDock.title = @"Hide from Dock";
		}
		
		[[NSApplication sharedApplication] stopModal];
	} else {
		if ([userDefaults boolForKey:@"HideFromDock"]) {
			
			TSEvent *e = [TSEvent eventWithName:@"mac-unixtimestamp-showdock" oneTimeOnly:NO];
			[[TSTapstream instance] fireEvent:e];
			
			NSLog(@"Show in Dock");
			[userDefaults setBool:NO forKey:@"HideFromDock"];
		} else {
			
			TSEvent *e = [TSEvent eventWithName:@"mac-unixtimestamp-hidedock" oneTimeOnly:NO];
			[[TSTapstream instance] fireEvent:e];
			
			
			NSLog(@"Hide from Dock");
			[userDefaults setBool:YES forKey:@"HideFromDock"];
		}
		[userDefaults synchronize];
		[self hideFromDock:nil];
	}
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	
	[self hideFromDock:nil];
	
	TSConfig *config = [TSConfig configWithDefaults];
	[TSTapstream createWithAccountName:@"unixtimestamp" developerSecret:@"UdawggWLSCuh4_aJFv0cYQ" config:config];
	
	
	opTag = 1;
	calculatorResultCell.title = @"";
	calculatorResultCell2.title = @"";
	
	Start_Date.title = @"";
	Start_Time.title = @"";
	
	End_Date.title = @"";
	End_Time.title = @"";
	
	End_Date2.title = @"";
	End_Time2.title = @"";
	
	
	// Insert code here to initialize your application
	[_window setDelegate:self];
	
	
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:[NSImage imageNamed:@"Icon.png"]];
	[statusItem setHighlightMode:YES];
	
	[[NSApplication sharedApplication] stopModal];
	//[NSApp setPresentationOptions: NSApplicationPresentationHideMenuBar | NSApplicationPresentationHideDock];
	
	
	
	
	[self ChangeTime:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]]];
	unixTimeStampCell.title = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
	
}

-(IBAction)NowDate:(id)sender {
	
	TSEvent *e = [TSEvent eventWithName:@"mac-unixtimestamp-now" oneTimeOnly:NO];
	[[TSTapstream instance] fireEvent:e];
	
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
	
	[self showOtherDates];
}

-(void) showOtherDates {
	
	NSString *date = [NSString stringWithString:[dateCell title]];
	NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
	[inFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *parsed = [inFormat dateFromString:date];
	
	NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
	[outFormat setDateFormat:@"yyyy-MM-dd 00:00:00"];
	NSString *dateString = [outFormat stringFromDate:parsed];
	
	parsed = [inFormat dateFromString:dateString];
	
	NSLog(@"%@ -> %d",dateString,(int)[parsed timeIntervalSince1970]);
	
	Start_Date.title=[NSString stringWithFormat:@"%@",dateString];
	Start_Time.title=[NSString stringWithFormat:@"%d",(int)[parsed timeIntervalSince1970]];
	
	NSDate *d = [NSDate dateWithTimeIntervalSince1970:((int)[parsed timeIntervalSince1970]+86399)];
	NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:((int)[parsed timeIntervalSince1970]+86400)];
	
	NSString *dateString2 = [inFormat stringFromDate:d];
	NSString *dateString3 = [inFormat stringFromDate:d2];
	
	NSLog(@"%@ -> %d",dateString2,(int)[d timeIntervalSince1970]);

	NSLog(@"%@ -> %d",dateString3,(int)[d2 timeIntervalSince1970]);
	
	End_Date.title=[NSString stringWithFormat:@"%@",dateString2];
	End_Time.title=[NSString stringWithFormat:@"%d",(int)[d timeIntervalSince1970]];
	
	End_Date2.title=[NSString stringWithFormat:@"%@",dateString3];
	End_Time2.title=[NSString stringWithFormat:@"%d",(int)[d2 timeIntervalSince1970]];
	

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
	[self showOtherDates];
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
	
	TSEvent *e = [TSEvent eventWithName:@"mac-unixtimestamp-calculate" oneTimeOnly:NO];
	[[TSTapstream instance] fireEvent:e];

	
	
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
	NSLog(@"windowWillClose");
}

- (BOOL)windowShouldClose:(id)sender {
	NSLog(@"windowShouldClose");
	
	TSEvent *e = [TSEvent eventWithName:@"mac-unixtimestamp-hide" oneTimeOnly:NO];
	[[TSTapstream instance] fireEvent:e];
	
	[[NSApplication sharedApplication] hide:self];
	return NO;
}

-(IBAction) applicationUnHide:(id)sender {
	NSLog(@"applicationUnHide");
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[NSApplication sharedApplication] unhide:self];

	TSEvent *e = [TSEvent eventWithName:@"mac-unixtimestamp-unhide" oneTimeOnly:NO];
	[[TSTapstream instance] fireEvent:e];
	
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
	NSLog(@"applicationShouldHandleReopen");
	[[NSApplication sharedApplication] unhide:self];
	
	TSEvent *e = [TSEvent eventWithName:@"mac-unixtimestamp-unhide" oneTimeOnly:NO];
	[[TSTapstream instance] fireEvent:e];
	
	return YES;
}




@end
