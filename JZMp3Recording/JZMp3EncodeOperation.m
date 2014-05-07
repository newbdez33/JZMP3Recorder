//
//  JZMp3EncodeOperation.m
//
// Copyright (c) 2014 Jacky<newbdez33@gmail.com> (http://jiezhang.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "JZMp3EncodeOperation.h"
#import "lame.h"


// GLobal var
lame_t lame;

@implementation JZMp3EncodeOperation

- (void)main
{
    
    if (!_currentMp3File) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _currentMp3File = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", [NSDate date]]];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_currentMp3File]) {
        [[NSFileManager defaultManager] createFileAtPath:_currentMp3File contents:[@"" dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:_currentMp3File];
    [handle seekToEndOfFile];

    
    // lame param init
    lame = lame_init();
	lame_set_num_channels(lame, 1);
	lame_set_in_samplerate(lame, 16000);
	lame_set_brate(lame, 128);
	lame_set_mode(lame, 1);
	lame_set_quality(lame, 2);
	lame_init_params(lame);
    
    while (true) {
        
        NSData *audioData = nil;
        @synchronized(_recordQueue){// begin @synchronized
            
            if (_recordQueue.count > 0) {
                audioData = [_recordQueue objectAtIndex:0];
                [_recordQueue removeObjectAtIndex:0];
            }
        }// end @synchronized
        
        if (audioData != nil) {
                        
            short *recordingData = (short *)audioData.bytes;
            NSUInteger pcmLen = audioData.length;
            NSUInteger nsamples = pcmLen / 2;
            
            unsigned char buffer[pcmLen];
            // mp3 encode
            int recvLen = lame_encode_buffer(lame, recordingData, recordingData, (int)nsamples, buffer, (int)pcmLen);

            NSData *piece = [NSData dataWithBytes:buffer length:recvLen];
            [handle writeData:piece];
            
        }else{
            if (_setToStopped) {
                break;
            }else{
                [NSThread sleepForTimeInterval:0.05];
            }
        }
        
    }
    
    [handle closeFile];
    
    lame_close(lame);
    
}

@end
