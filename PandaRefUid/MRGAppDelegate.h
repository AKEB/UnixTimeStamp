//
//  MRGAppDelegate.h
//  PandaRefUid
//
//  Created by Вадим Бабаджанян on 9/8/11.
//  Copyright (c) 2011 "АйТи Территория". All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MRGAppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate> {
	NSTextFieldCell 	*dateCell;
	NSTextFieldCell 	*unixTimeStampCell;
	NSTextFieldCell 	*fullDate;
	
	NSTextFieldCell 	*intCell1;
	NSTextFieldCell 	*intCell2;
	
	NSTextFieldCell *calculatorResultCell;
	NSTextFieldCell *calculatorResultCell2;
	
	NSWindow            *_window;
	NSMenu              *statusMenu;
	NSMenuItem          *myMenuStatusItem;
	NSStatusItem 		*statusItem;
	
	int opTag;
}



@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSMenu *statusMenu;
@property (strong) IBOutlet NSMenuItem *myMenuStatusItem;
@property (strong) IBOutlet NSTextFieldCell *dateCell;
@property (strong) IBOutlet NSTextFieldCell *unixTimeStampCell;
@property (strong) IBOutlet NSTextFieldCell *fullDate;
@property (strong) IBOutlet NSTextFieldCell *intCell1;
@property (strong) IBOutlet NSTextFieldCell *intCell2;

@property (strong) IBOutlet NSTextFieldCell *calculatorResultCell;
@property (strong) IBOutlet NSTextFieldCell *calculatorResultCell2;


-(IBAction)NowDate:(id)sender;
-(IBAction)ChangeCalcOp:(id)sender;
-(IBAction)ChangeDate:(id)sender;
-(IBAction)Calculate:(id)sender;

-(void)ChangeTime:(NSString *)unixTime;
@end
