//
//  FirstWindowController.m
//  MacLin
//
//  Created by yu_hao on 10/28/13.
//  Copyright (c) 2013 yu_hao. All rights reserved.
//

#import "FirstWindowController.h"
#import "macUser.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#import <CFNetwork/CFNetwork.h>

@interface FirstWindowController ()
{
    NSMutableArray *remoteMac;
    
    CFSocketRef             _ipv4socket;
    CFSocketRef             _ipv6socket;
}

@end

@implementation FirstWindowController

@synthesize inputStream  = inputStream;
@synthesize outputStream = outputStream;

- (id)init {
    NSLog(@"init");
    self = [super initWithWindowNibName:@"FirstWindowController"];
    
    macUser *one = [[macUser alloc] init];
    one.name = @"yu";
    one.IP = @"118.228.173.165";
    one.ID = @"111114114";
    remoteMac = [[NSMutableArray alloc] init];
    [remoteMac addObject:one];
    macUser *two = [[macUser alloc] init];
    two.name = @"yu";
    two.IP = @"118.228.173.178";
    two.ID = @"111114114";
    [remoteMac addObject:two];
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"MacCell" owner:self];
    //NSLog(@"Field = %@", cellView.textField);
    
    NSLog(@"ServiceColumn is ok.");
    cellView.imageView.image = nil;
    macUser *one = [remoteMac objectAtIndex:row];
    cellView.textField.stringValue = one.IP;
    
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return remoteMac.count;
}

- (IBAction)tableViewSelect:(id)sender {
    NSTableView * table = (NSTableView *) sender;
    NSInteger selectedRow = [table selectedRow];
    
    if (selectedRow >= 0) {
        macUser *one = [remoteMac objectAtIndex:selectedRow];
        [self startSend:one.IP];
    }
}

- (BOOL)startSend:(NSString *)ip
{
    NSLog(@"ready to send to %@", ip);
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ip, 30228, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    
    return YES;
}

- (IBAction)sendReturn:(id)sender {
    NSString *response  = [NSString stringWithFormat:@"message=%@", [sender stringValue]];
    NSLog(@"%@", response);
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

@end
