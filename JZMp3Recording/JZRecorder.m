//
//  JZRecorder.m
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

#import "JZRecorder.h"
#import <AVFoundation/AVFoundation.h>

static const int bufferByteSize = 1600;
static const int sampeleRate = 16000;
static const int bitsPerChannel = 16;

@implementation JZRecorder

// 设置录音格式
- (void) setupAudioFormat:(UInt32) inFormatID SampleRate:(int) sampeleRate
{
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    _recordFormat.mSampleRate = sampeleRate;
    
	//UInt32 size = sizeof(_recordFormat.mChannelsPerFrame);
    //AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels, &size, &_recordFormat.mChannelsPerFrame);
	_recordFormat.mFormatID = inFormatID;
	if (inFormatID == kAudioFormatLinearPCM){
		// if we want pcm, default to signed 16-bit little-endian
        _recordFormat.mChannelsPerFrame = 1;
		_recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
		_recordFormat.mBitsPerChannel = bitsPerChannel;
		_recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
		_recordFormat.mFramesPerPacket = 1;
	}
    
}

// 回调函数
void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,
                        UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    JZRecorder *recorder = (__bridge JZRecorder *)inUserData;
    if (inNumPackets > 0 && recorder.isRecording){
        
        int pcmSize = inBuffer->mAudioDataByteSize;
        char *pcmData = (char *)inBuffer->mAudioData;
        NSData *data = [[NSData alloc] initWithBytes:pcmData length:pcmSize];
        [recorder.recordQueue addObject:data];
        
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

// 开始录音
- (void) startRecording
{

    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // category
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
    // format
    [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:sampeleRate];
    
    // 设置回调函数
    AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
    
    
    // 创建缓冲器
    for (int i = 0; i < kNumberAudioQueueBuffers; ++i){
        AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
        AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
    }
    
    // 开始录音
    AudioQueueStart(_audioQueue, NULL);
    _isRecording = YES;
   
}

// 停止录音
- (void) stopRecording
{
    if (_isRecording) {
        
        _isRecording = NO;
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
    }
}

@end
