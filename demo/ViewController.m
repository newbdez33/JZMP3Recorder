//
//  ViewController.m
//  demo
//
//  Created by Jacky <newbdez33@gmail.com> on 7/05/2014.
//  Copyright (c) 2014 Salmonapps. All rights reserved.
//

#import "ViewController.h"
#import "JZMp3RecordingClient.h"

@interface ViewController () {
    IBOutlet UIButton *recordButton;
    JZMp3RecordingClient *recordClient;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //init client
    recordClient = [JZMp3RecordingClient sharedClient];
}

- (IBAction)toggleRecord:(id)sender {
    
    if ([recordButton.titleLabel.text isEqualToString:@"Record"]) {
        [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *mp3 = [path stringByAppendingPathComponent:@"test.mp3"];
        [recordClient setCurrentMp3File:mp3];
        [recordClient start];
    }else {
        [recordButton setTitle:@"Record" forState:UIControlStateNormal];
        [recordClient stop];
    }
    
}

@end
