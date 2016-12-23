//
//  AlertViewController.m
//  Socket_client
//
//  Created by lihongfeng on 16/12/22.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "AlertViewController.h"

@interface AlertViewController ()

@property (strong) IBOutlet NSTextField *infoLabel;
@property (strong) IBOutlet NSButton *okButton;

@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.infoLabel.stringValue = self.infoString;
}

- (IBAction)okAction:(id)sender {
    [self dismissController:self];
}

@end
