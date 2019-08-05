//
//  DSEmulatorBridge.m
//  DSDeltaCore
//
//  Created by Riley Testut on 8/2/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import "DSEmulatorBridge.h"

#import <DSDeltaCore/DSDeltaCore-Swift.h>

@interface DSEmulatorBridge ()

@property (nonatomic, copy, nullable, readwrite) NSURL *gameURL;

@end

@implementation DSEmulatorBridge
@synthesize audioRenderer = _audioRenderer;
@synthesize videoRenderer = _videoRenderer;
@synthesize saveUpdateHandler = _saveUpdateHandler;

+ (instancetype)sharedBridge
{
    static DSEmulatorBridge *_emulatorBridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emulatorBridge = [[self alloc] init];
    });
    
    return _emulatorBridge;
}

#pragma mark - Emulation State -

- (void)startWithGameURL:(NSURL *)gameURL
{
}

- (void)stop
{
}

- (void)pause
{
}

- (void)resume
{
}

#pragma mark - Game Loop -

- (void)runFrame
{
}

#pragma mark - Inputs -

- (void)activateInput:(NSInteger)input value:(double)value
{
}

- (void)deactivateInput:(NSInteger)input
{
}

- (void)resetInputs
{
}

#pragma mark - Game Saves -

- (void)saveGameSaveToURL:(NSURL *)URL
{
}

- (void)loadGameSaveFromURL:(NSURL *)URL
{
}

#pragma mark - Save States -

- (void)saveSaveStateToURL:(NSURL *)URL
{
}

- (void)loadSaveStateFromURL:(NSURL *)URL
{
}

#pragma mark - Cheats -

- (BOOL)addCheatCode:(NSString *)cheatCode type:(NSString *)type
{
    return NO;
}

- (void)resetCheats
{
}

- (void)updateCheats
{
}

#pragma mark - Getters/Setters -

- (NSTimeInterval)frameDuration
{
    return (1.0 / 60.0);
}

@end
