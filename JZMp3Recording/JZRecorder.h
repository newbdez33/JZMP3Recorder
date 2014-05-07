//
//  JZRecorder.h
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
//
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

#define kNumberAudioQueueBuffers 3
#define kBufferDurationSeconds 0.1f


@interface JZRecorder : NSObject
{
    AudioQueueRef				_audioQueue;
    AudioQueueBufferRef			_audioBuffers[kNumberAudioQueueBuffers];
    AudioStreamBasicDescription	_recordFormat;
    
}

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSMutableArray *recordQueue;

- (void) startRecording;
- (void) stopRecording;


@end
