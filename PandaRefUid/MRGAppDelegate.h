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
	NSTextFieldCell     *Start_Date;
	NSTextFieldCell     *Start_Time;
	NSTextFieldCell     *End_Date;
	NSTextFieldCell     *End_Time;
	NSTextFieldCell     *End_Date2;
	NSTextFieldCell     *End_Time2;
	
	
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
@property (strong) IBOutlet NSTextFieldCell *Start_Date;
@property (strong) IBOutlet NSTextFieldCell *Start_Time;

@property (strong) IBOutlet NSTextFieldCell *End_Date;
@property (strong) IBOutlet NSTextFieldCell *End_Time;
@property (strong) IBOutlet NSTextFieldCell *End_Date2;
@property (strong) IBOutlet NSTextFieldCell *End_Time2;


@property (strong) IBOutlet NSTextFieldCell *calculatorResultCell;
@property (strong) IBOutlet NSTextFieldCell *calculatorResultCell2;


-(IBAction)NowDate:(id)sender;
-(IBAction)ChangeCalcOp:(id)sender;
-(IBAction)ChangeDate:(id)sender;
-(IBAction)Calculate:(id)sender;

-(void)ChangeTime:(NSString *)unixTime;
-(void) showOtherDates;

@end
