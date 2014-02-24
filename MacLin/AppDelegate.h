//
//  AppDelegate.h
//  MacLin
//
//  Created by yu_hao on 10/28/13.
//  Copyright (c) 2013 yu_hao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDelegate>
{
    IBOutlet NSPanel *theSheet;
    IBOutlet NSPanel *enterSheet;
    IBOutlet NSPanel *updateSheet;
    NSImage *GreenButtonColor;
    NSImage *GreenButtonGrey;
    NSString *userAccountString;
    NSString *userPasswordString;
    NSString *currentIP;
    NSTimer *networkTimer;
    NSTimer *forbidBittenTimer;
    
    int networkStatus;
    float incomeNum;
    float outputNum;
    int forbidRecall;
    int forbidRefuse;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSMutableArray *subWindowArray;
@property (strong) IBOutlet WebView *webView;
@property (weak) IBOutlet NSTextField *incomeLabel;
@property (weak) IBOutlet NSTextField *outputLabel;
@property (weak) IBOutlet NSTextField *hintLabel;
@property (weak) IBOutlet NSImageView *hintImage;
@property (weak) IBOutlet NSTextField *userAccount;
@property (weak) IBOutlet NSTextField *userPassword;
@property (weak) IBOutlet NSTextField *saveHintLabel;
@property (weak) IBOutlet NSButton *checkbox;

@property (weak) IBOutlet NSView *windowView;
@property (weak) IBOutlet NSTextField *updateLabel;

- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)showMore:(id)sender;
- (IBAction)findFriend:(id)sender;
- (IBAction)getHelp:(id)sender;
- (IBAction)showTheSheet:(id)sender;
- (IBAction)endTheSheet:(id)sender;

- (IBAction)enableFacebook:(id)sender;
- (IBAction)applescriptCopy:(id)sender;
- (IBAction)enterAccount:(id)sender;
- (IBAction)saveAccount:(id)sender;
- (IBAction)cancelEnter:(id)sender;
- (IBAction)cancelUpdate:(id)sender;

- (void)connectToInternet;
- (void)checkInternet;
- (void)checkUpdate;

@end
