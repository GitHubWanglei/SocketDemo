//
//  ViewController.m
//  Socket_server
//
//  Created by lihongfeng on 16/12/21.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AlertViewController.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (strong) IBOutlet NSTextField *statusLabel;
@property (strong) IBOutlet NSTextView *displayView;
@property (strong) IBOutlet NSTextView *inputView;
@property (strong) IBOutlet NSButton *sendButton;
@property (strong) IBOutlet NSScrollView *displayScrollView;

@property (nonatomic, strong) GCDAsyncSocket *servierSocket;
@property (nonatomic, strong) GCDAsyncSocket *receiveSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.displayView.string = @"";
    self.displayScrollView.autohidesScrollers = YES;
    
    self.servierSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [self.servierSocket acceptOnPort:8000 error:&error];
    if (error) {
        NSLog(@"[server]: error: %@", error.description);
        return;
    }
    
}

- (IBAction)sendAction:(NSButton *)sender {
    if (self.inputView.string.length > 0 && self.receiveSocket.isConnected == YES) {
        [self writeDataWithString:self.inputView.string];
    }else{
        if (self.receiveSocket.isConnected == NO) {
            NSLog(@"[client]: 连接中...");
            NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            AlertViewController *alertVC = [sb instantiateControllerWithIdentifier:@"alertVC"];
            alertVC.infoString = @"正在连接中, 请稍后......";
            [self presentViewControllerAsSheet:alertVC];
        }else if (self.inputView.string.length == 0) {
            NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            AlertViewController *alertVC = [sb instantiateControllerWithIdentifier:@"alertVC"];
            alertVC.infoString = @"请输入聊天内容.";
            [self presentViewControllerAsSheet:alertVC];
        }
    }
}

- (void)writeDataWithString:(NSString *)string {
    [self.receiveSocket writeData:[string dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:101];
}

#pragma mark 有客户端建立连接  sock 服务端  newSocket 客户端
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"[server]: 有客户端连接进来了...");
    self.statusLabel.stringValue = @"✅ 连接成功.";
    self.receiveSocket = newSocket;
    self.receiveSocket.delegate = self;
    [self.receiveSocket readDataWithTimeout:-1 tag:100];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"[server]: DidDisconnect error: %@", err);
    self.statusLabel.stringValue = @"⛔️ 连接中...";
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"[server]读取信息成功: data: %@, tag: %ld", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], tag);
    NSString *receiveString = [NSString stringWithFormat:@" %@: %@\n", @"192.168.87.195",
                               [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    [self updateDisplayViewWithString:receiveString clearInputView:NO];
    [self.receiveSocket readDataWithTimeout:-1 tag:100];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"[client]: 写入(tag: %ld)信息成功.", tag);
    NSString *sendString = [NSString stringWithFormat:@" %@: %@\n", [self getIPAddress], self.inputView.string];
    [self updateDisplayViewWithString:sendString clearInputView:YES];
}

- (void)updateDisplayViewWithString:(NSString *)string clearInputView:(BOOL)clear{
    self.displayView.string = [self.displayView.string stringByAppendingString:string];
    if (clear) {
        self.inputView.string = @"";
    }
    [self.displayScrollView.verticalScroller scrollPoint:CGPointMake(464, 464)];
}

#pragma mark - 获取设备 IP 地址
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

@end








