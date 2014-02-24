//
//  AppDelegate.m
//  MacLin
//
//  Created by yu_hao on 10/28/13.
//  Copyright (c) 2013 yu_hao. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstWindowController.h" 
#import "Reachability.h"
#import "SimplePingHelper.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    self.subWindowArray = [[NSMutableArray alloc] init];
    [_window setReleasedWhenClosed:NO];
    [_window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"bg.png"]]];
    
    forbidRecall = 1;
    forbidRefuse = 1;
    GreenButtonColor = [NSImage imageNamed:@"GreenButtonColor"];
    GreenButtonGrey = [NSImage imageNamed:@"GreenButtonGrey"];
    
    NSString *pathK = [[NSBundle mainBundle] pathForResource:@"key" ofType:nil];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:pathK];
    NSDictionary *dataDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:dataFromFile];
    if (dataDictionary == nil || [[dataDictionary objectForKey:@"userPassword"] isEqualToString:@""]) {
        [self showEnterAccountSheet];
    }else
    {
        userAccountString = [dataDictionary objectForKey:@"userAccount"];
        userPasswordString = [dataDictionary objectForKey:@"userPassword"];
        NSLog(@"文件里的账号是 %@", userAccountString);
        
        [self checkUpdate];
    }
    
    //因为nstimer不会立即执行，所以先手动检查一下
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkInternet];
    });
    networkTimer = [NSTimer scheduledTimerWithTimeInterval: 30.0
                                     target: self
                                   selector:@selector(checkInternet)
                                   userInfo: nil repeats:YES];
    
    forbidBittenTimer = [NSTimer scheduledTimerWithTimeInterval: 300.0
                                                           target: self
                                                         selector:@selector(forbidBitten)
                                                         userInfo: nil repeats:YES];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [_window setIsVisible:YES];
    return YES;
}

- (IBAction)login:(id)sender {
    if (userAccountString == nil || [userAccountString isEqualToString:@""] || [userPasswordString isEqualToString:@""]) {
        [self showEnterAccountSheet];
    }else{
        [self connectToInternet];
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self checkInternet];
//    });
}

- (IBAction)logout:(id)sender {
    if (userAccountString == nil || [userAccountString isEqualToString:@""] || [userPasswordString isEqualToString:@""]) {
        [self showEnterAccountSheet];
    }else{
        [self disconnect];
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self checkInternet];
//    });
}

- (void)showEnterAccountSheet
{
    [NSApp beginSheet:enterSheet
       modalForWindow:(NSWindow *)_window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (IBAction)enterAccount:(id)sender {
    [self showEnterAccountSheet];
}

- (IBAction)saveAccount:(id)sender {
    NSDictionary *accountDic = [NSDictionary dictionaryWithObjectsAndKeys:self.userAccount.stringValue, @"userAccount", self.userPassword.stringValue, @"userPassword", nil];
    NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:accountDic];
    NSString *pathK = [[NSBundle mainBundle] pathForResource:@"key" ofType:nil];
    if([accountData writeToFile:pathK atomically:YES])
    {
        NSLog(@"writing is ok!");
        self.hintLabel.stringValue = @"账号保存成功";
        userAccountString = self.userAccount.stringValue;
        userPasswordString = self.userPassword.stringValue;
    }
    
    [NSApp endSheet:enterSheet];
    [enterSheet orderOut:sender];
}

- (IBAction)cancelEnter:(id)sender {
    [NSApp endSheet:enterSheet];
    [enterSheet orderOut:sender];
}

- (IBAction)findFriend:(id)sender {
    FirstWindowController *findFriendWindow = [[FirstWindowController alloc] init];
    // need to hold onto a reference to this object.
    [self.subWindowArray addObject:findFriendWindow];
    [findFriendWindow showWindow:self];
}

- (IBAction)showMore:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://login.bjfu.edu.cn"]];
}

- (IBAction)getHelp:(id)sender {
    NSString *urlString = @"http://118.228.173.165/programming/北林maclin官方服务区";
    NSString *string = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:string]];
}

- (IBAction)showTheSheet:(id)sender
{
    [NSApp beginSheet:theSheet
       modalForWindow:(NSWindow *)_window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

-(IBAction)endTheSheet:(id)sender
{
    [NSApp endSheet:theSheet];
    [theSheet orderOut:sender];
    NSString *pathF = [[NSBundle mainBundle] pathForResource:@"hosts" ofType:nil];
    [[NSWorkspace sharedWorkspace] selectFile:@"/private/etc/hosts" inFileViewerRootedAtPath:@"/private/etc/"];
    [[NSWorkspace sharedWorkspace] selectFile:pathF inFileViewerRootedAtPath:[pathF stringByDeletingLastPathComponent]];
}

- (IBAction)enableFacebook:(id)sender {
    NSString *pathF = [[NSBundle mainBundle] pathForResource:@"hosts" ofType:nil];
//    NSError *facebookError = nil;
//    NSString *facebook = [NSString stringWithContentsOfFile:pathF encoding:NSUTF8StringEncoding error:&facebookError];
    
//    if(!facebook) {
//        NSLog(@"%@", facebookError);
//        NSLog(@"读取错误");
//    }else{
//        NSLog(@"%@", facebook);
//    }
    
//    NSURL *fileURL = [NSURL URLWithString:@"/Users/Facebook.txt"];
//    NSArray *fileURLs = [NSArray arrayWithObjects:filePath, nil];
    [[NSWorkspace sharedWorkspace] selectFile:@"/private/etc/hosts" inFileViewerRootedAtPath:@"/private/etc/"];
    [[NSWorkspace sharedWorkspace] selectFile:pathF inFileViewerRootedAtPath:[pathF stringByDeletingLastPathComponent]];
    
//    NSURL *fileURL = [NSURL URLWithString:pathF];
//    NSURL *fileURLTo = [NSURL URLWithString:@"/private"];
//    if ( [[NSFileManager defaultManager] isReadableFileAtPath:pathF] )
//        [[NSFileManager defaultManager] copyItemAtPath:pathF toPath:nil error:&facebookError];
//    NSLog(@"%@", facebookError);
}

- (IBAction)applescriptCopy:(id)sender
{
    // load the script from a resource by fetching its URL from within our bundle
    NSString* path = [[NSBundle mainBundle] pathForResource:@"HotspotScript" ofType:@"scpt"];
    
    if (path != nil)
    {
        NSURL* url = [NSURL fileURLWithPath:path];
        if (url != nil)
        {
            NSDictionary* errors = [NSDictionary dictionary];
            NSAppleScript* appleScript =
            [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
            if (appleScript != nil)
            {
                NSLog(@"开始执行开启hotspot脚本");
                [appleScript executeAndReturnError:&errors];
            }
            else
            {
                // report any errors from 'errors'
                NSLog(@"开启hotspot脚本调用失败");
            }
        }
    }
}

- (void)connectToInternet
{
    forbidRecall = 1;
    
    NSLog(@"准备连上 %@", [self getEthernetIPAddress]);
    if (![[self getEthernetIPAddress] isEqualToString:@"error"]) {
        currentIP = [self getEthernetIPAddress];
    }else if (![[self getWifiIPAddress] isEqualToString:@"error"])
    {
        currentIP = [self getWifiIPAddress];
    } else{
        NSLog(@"看来你的网线没接好而且wifi也没连上");
    }
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@&ip=%@&action=连接网络", userAccountString, userPasswordString, currentIP]; //172.19.5.231
    
    //首先声明一个encoding type，原理是将CF转化成NSString能用的
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //然后再加上百分号 //kCFStringEncodingGB_2312_80
    NSString *stringGBK = [postString stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    NSLog(@"%@", stringGBK);
    
    // Package the string in an NSData object，这个用utf-8编码成nsdata，无关痛痒
    NSData *requestData = [stringGBK dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[requestData length]];
    //NSLog(@"%@", postLength);
    
    // Create the URL request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://login.bjfu.edu.cn/checkLogin.jsp"]];  // create the URL request
    [request setHTTPMethod: @"POST"];   // you're sending POST data
    [request setHTTPBody: requestData];  // apply the post data to be sent
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Call the URL
    NSURLConnection * connection = [[NSURLConnection alloc]
                                    initWithRequest:request
                                    delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
}

- (void)disconnect
{
    forbidRecall = 0; //为了平衡断网时调用的次数多了一次
    
    NSLog(@"准备断开 %@", [self getEthernetIPAddress]);
    if (![[self getEthernetIPAddress] isEqualToString:@"error"]) {
        currentIP = [self getEthernetIPAddress];
    }else if (![[self getWifiIPAddress] isEqualToString:@"error"])
        {
            currentIP = [self getWifiIPAddress];
        } else{
            NSLog(@"看来你的网线没接好而且wifi也没连上");
        }
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@&ip=%@&action=中断连网", userAccountString, userPasswordString, currentIP];
    
    //首先声明一个encoding type，原理是将CF转化成NSString能用的
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //然后再加上百分号 //kCFStringEncodingGB_2312_80
    NSString *stringGBK = [postString stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    NSLog(@"%@", stringGBK);
    
    // Package the string in an NSData object，这个用utf-8编码成nsdata，无关痛痒
    NSData *requestData = [stringGBK dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[requestData length]];
    //NSLog(@"%@", postLength);
    
    // Create the URL request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://login.bjfu.edu.cn/checkLogin.jsp"]];  // create the URL request
    [request setHTTPMethod: @"POST"];   // you're sending POST data
    [request setHTTPBody: requestData];  // apply the post data to be sent
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Call the URL
    NSURLConnection * connection = [[NSURLConnection alloc]
                                    initWithRequest:request
                                    delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"收到服务器应答头文件");
    
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//    NSDictionary *dic = [httpResponse allHeaderFields];
//    for(NSString *key in [dic allKeys]) {
//        NSLog(@"%@",[dic objectForKey:key]);
//    }
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"收到服务器应答数据");
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *strData = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    NSLog(@"%@", strData);
    
    [self.webView setFrameLoadDelegate:self];
    NSURL *baseURL = [NSURL URLWithString:@"http://login.bjfu.edu.cn/user/"];
    [[self.webView mainFrame] loadData:data MIMEType: @"text/html" textEncodingName: @"gbkEncoding" baseURL:baseURL];
}

 - (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    forbidRecall++;
    NSLog(@"开始载入执行页面");
    if (8 == forbidRecall)
    {
        NSLog(@"最后一个脚本已经加载完毕，开始解析文本");
        forbidRecall = 1;
        //获得连网提示信息
        NSString *hint1 = [self.webView stringByEvaluatingJavaScriptFromString:@"window.frames['main'].document.getElementsByClassName('left_bt2')[0].innerText"];
        //断网时候的提示信息
        NSString *hint2 = [self.webView stringByEvaluatingJavaScriptFromString:@"window.frames['main'].document.getElementsByClassName('form_txt')[0].innerText"];
        
        //说明是在连网
        if (![hint1 isEqualToString:@""]) {
            //获得入流量的值
            NSString *remainIncome = [self.webView stringByEvaluatingJavaScriptFromString:@"window.frames['main'].document.getElementsByClassName('form_td_middle')[8].innerText"];
            self.incomeLabel.stringValue = remainIncome;
            //NSLog(@"插入javascript获得的值: %@", remainIncome);
            NSString *string1 = [remainIncome substringToIndex:3];
            incomeNum =string1.floatValue;
            if (incomeNum < 0.7) {
                self.incomeLabel.textColor = [NSColor redColor];
                if ([self.checkbox state] == NSOnState) {
                    [self disconnect];
                }else
                {
                    self.hintLabel.stringValue = hint1;
                }
            }else
            {
                self.hintLabel.stringValue = hint1;
            }
            //获得出流量的值
            NSString *remainOutput = [self.webView stringByEvaluatingJavaScriptFromString:@"window.frames['main'].document.getElementsByClassName('form_td_right')[4].innerText"];
            self.outputLabel.stringValue = remainOutput;
            //NSLog(@"插入javascript获得的值: %@", remainOutput);
            NSString *string2 = [remainOutput substringToIndex:3];
            outputNum =string2.floatValue;
            if (outputNum < 0.6) {
                self.outputLabel.textColor = [NSColor redColor];
                if ([self.checkbox state] == NSOnState) {
                    [self disconnect];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkInternet];
            });
        }
        //说明是在断网
        if (![hint2 isEqualToString:@""]) {
            if (incomeNum < 0.7 && [self.checkbox state] == NSOnState)
            {
                self.hintLabel.stringValue = @"你入流量快超了！已经自动断网，若要继续上网，请关闭流量监视！";
            }else
            {
                self.hintLabel.stringValue = hint2;
            }
            if (outputNum < 0.6 && [self.checkbox state] == NSOnState)
            {
                self.hintLabel.stringValue = @"你出流量快超了！已经自动断网，若要继续上网，请关闭流量监视！";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkInternet];
            });
        }
    }
    //如果密码不对，则页面只会载入三次
    else if (forbidRecall == 3)
        {
            self.hintLabel.stringValue = @"开始校验密码，若此时提示没更新，则可能密码不对";
        }
}

- (void)checkInternet
{
    // 用于检测网络是否畅通
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    
    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
	reach.reachableOnWWAN = NO;
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Block Says Reachable");
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Block Says UnReachable");
        });
    };
    
    //可以保持reach这个object
    [reach startNotifier];
     */
    
    //上面的方法因为dns的原因会造成不准确，最好还是用下面ping的方法，这里ping的是百度
    NSString *pingURL = nil;
    if (7 == forbidRefuse) {
        forbidRefuse = 1;
    }
    switch (forbidRefuse) {
        case 1:
            pingURL = @"www.baidu.com";
            forbidRefuse++;
            break;
        case 2:
            pingURL = @"www.qq.com";
            forbidRefuse++;
            break;
        case 3:
            pingURL = @"www.renren.com";
            forbidRefuse++;
            break;
        case 4:
            pingURL = @"www.youku.com";
            forbidRefuse++;
            break;
        case 5:
            pingURL = @"www.jd.com";
            forbidRefuse++;
            break;
        case 6:
            pingURL = @"www.bing.com.cn";
            forbidRefuse++;
            break;
            
        default:
            break;
    }
    [SimplePingHelper ping:@"www.baidu.com"
                    target:self sel:@selector(pingResult:)];
}

-(void)reachabilityChanged:(NSNotification*)note
{
//    Reachability * reach = [note object];
//    
//    if([reach isReachable])
//    {
//        NSLog(@"NSNotification Says Reachable");
//    }
//    else
//    {
//        NSLog(@"NSNotification Says UnReachable");
//    }
}

- (void)pingResult:(NSNumber*)success {
    if (success.boolValue) {
        NSLog(@"SUCCESS url: %d", forbidRefuse-1);
        networkStatus = 1;
        self.hintImage.image = GreenButtonColor;
    } else {
        NSLog(@"FAILURE url: %d", forbidRefuse-1);
        networkStatus = 0;
        self.hintImage.image = GreenButtonGrey;
    }
}

- (NSString *)getEthernetIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (NSString *)getWifiIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (void)forbidBitten
{
    if (1 == networkStatus && [self.checkbox state] == NSOnState) {
        NSLog(@"自动检测流量");
        [self connectToInternet];
    }
}

- (void)checkUpdate
{
    //为了避免同时显示sheet，比如软件启动时候会检查用户账号，所以最好在之前的判断语句后调用
    NSString* path = @"http://118.228.173.165/update.txt";
    NSString *stringUTF = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:stringUTF];
    __block NSError *error = nil;
    if (url != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSData *URLData = [NSData dataWithContentsOfURL:url];
            NSString *getNew = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
            if (!error && ![getNew hasPrefix:@"0"]) {
                self.updateLabel.stringValue = getNew;
                [self performSelectorOnMainThread:@selector(showUpdate) withObject:nil waitUntilDone:NO];
            }else
            {
                NSLog(@"获取data出错或者不显示更新！");
            }
//            if (URLData != nil) {
//                NSString *remoteString = (NSString*) [NSKeyedUnarchiver unarchiveObjectWithData:URLData];
//                self.updateLabel.stringValue = remoteString;
//                if (remoteString != nil || ![remoteString isEqualToString:@""]) {
//                    will = 1;
//                }
//            }else
//            {
//                NSLog(@"获取data出错！");
//            }
        });
        
//        if (!error && [self.updateLabel.stringValue characterAtIndex:1] != 0) {
//           
//        }
    }
}

- (void)showUpdate
{
    [NSApp beginSheet:updateSheet
       modalForWindow:(NSWindow *)_window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (IBAction)cancelUpdate:(id)sender {
    [NSApp endSheet:updateSheet];
    [updateSheet orderOut:sender];
}

@end
