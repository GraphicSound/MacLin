//
//  FirstWindowController.h
//  MacLin
//
//  Created by yu_hao on 10/28/13.
//  Copyright (c) 2013 yu_hao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FirstWindowController : NSWindowController <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource, NSStreamDelegate, NSTextFieldDelegate>

@property (nonatomic, assign, readwrite) NSUInteger         port;
@property (nonatomic, assign, readwrite) IBOutlet NSTextField * responseField;
@property (weak) IBOutlet NSTextField *sendTextfield;
- (IBAction)sendReturn:(id)sender;

@property (nonatomic, strong, readwrite) NSInputStream *        inputStream;
@property (nonatomic, strong, readwrite) NSOutputStream *       outputStream;
@property (nonatomic, strong, readwrite) NSMutableData *        inputBuffer;
@property (nonatomic, strong, readwrite) NSMutableData *        outputBuffer;

@end
