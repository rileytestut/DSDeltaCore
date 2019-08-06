//
//  DSEmulatorBridge.m
//  DSDeltaCore
//
//  Created by Riley Testut on 8/2/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import "DSEmulatorBridge.h"

#import <DSDeltaCore/DSDeltaCore-Swift.h>

// DeSmuME
#include "types.h"
#include "render3D.h"
#include "rasterize.h"
#include "SPU.h"
#include "debug.h"
#include "NDSSystem.h"
#include "path.h"
#include "slot1.h"
#include "saves.h"
#include "cheatSystem.h"
#include "slot1.h"
#include "version.h"
#include "metaspu.h"
#include "GPU.h"

#undef BOOL

#define SNDCORE_DELTA 1

void DLTAUpdateAudio(s16 *buffer, u32 num_samples);
u32 DLTAGetAudioSpace();

SoundInterface_struct DeltaAudio = {
    SNDCORE_DELTA,
    "CoreAudio Sound Interface",
    SNDDummy.Init,
    SNDDummy.DeInit,
    DLTAUpdateAudio,
    DLTAGetAudioSpace,
    SNDDummy.MuteAudio,
    SNDDummy.UnMuteAudio,
    SNDDummy.SetVolume,
};

volatile bool execute = true;

GPU3DInterface *core3DList[] = {
    &gpu3DNull,
    &gpu3DRasterize,
    NULL
};

SoundInterface_struct *SNDCoreList[] = {
    &SNDDummy,
    &DeltaAudio,
    NULL
};

@interface DSEmulatorBridge ()
{
    BOOL _isPrepared;
}

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
    self.gameURL = gameURL;
    
    path.ReadPathSettings();
    
    // General
    CommonSettings.num_cores = (int)sysconf( _SC_NPROCESSORS_ONLN );
    CommonSettings.advanced_timing = false;
    CommonSettings.cheatsDisable = true;
    CommonSettings.autodetectBackupMethod = 0;
    CommonSettings.use_jit = false;
    CommonSettings.micMode = TCommonSettings::Physical;
    CommonSettings.showGpu.main = 1;
    CommonSettings.showGpu.sub = 1;
    
    // HUD
    CommonSettings.hud.FpsDisplay = false;
    CommonSettings.hud.FrameCounterDisplay = false;
    CommonSettings.hud.ShowInputDisplay = false;
    CommonSettings.hud.ShowGraphicalInputDisplay = false;
    CommonSettings.hud.ShowLagFrameCounter = false;
    CommonSettings.hud.ShowMicrophone = false;
    CommonSettings.hud.ShowRTC = false;
    
    // Graphics
    CommonSettings.GFX3D_HighResolutionInterpolateColor = 0;
    CommonSettings.GFX3D_EdgeMark = 0;
    CommonSettings.GFX3D_Fog = 1;
    CommonSettings.GFX3D_Texture = 1;
    CommonSettings.GFX3D_LineHack = 0;
    
    // Sound
    CommonSettings.spuInterpolationMode = SPUInterpolation_Cosine;
    CommonSettings.spu_advanced = false;
    
    // Firmware
    CommonSettings.fwConfig.language = NDS_FW_LANG_ENG;
    CommonSettings.fwConfig.favoriteColor = 15;
    CommonSettings.fwConfig.birthdayMonth = 10;
    CommonSettings.fwConfig.birthdayDay = 7;
    CommonSettings.fwConfig.consoleType = NDS_CONSOLE_TYPE_LITE;
    
    static const char *nickname = "Delta";
    CommonSettings.fwConfig.nicknameLength = strlen(nickname);
    for(int i = 0 ; i < CommonSettings.fwConfig.nicknameLength ; ++i)
    {
        CommonSettings.fwConfig.nickname[i] = nickname[i];
    }
    
    static const char *message = "Delta is the best!";
    CommonSettings.fwConfig.messageLength = strlen(message);
    for(int i = 0 ; i < CommonSettings.fwConfig.messageLength ; ++i)
    {
        CommonSettings.fwConfig.message[i] = message[i];
    }
    
    if (!_isPrepared)
    {
        Desmume_InitOnce();
        
        NDS_Init();
        cur3DCore = 1;
        
        GPU->Change3DRendererByID(1);
        GPU->SetColorFormat(NDSColorFormat_BGR888_Rev);
        
        SPU_ChangeSoundCore(SNDCORE_DELTA, DESMUME_SAMPLE_RATE * 8/60);
        
        _isPrepared = true;
    }
    
    NSURL *gameDirectory = [gameURL URLByDeletingLastPathComponent];
    path.setpath(PathInfo::BATTERY, gameDirectory.fileSystemRepresentation);
    
    if (!NDS_LoadROM(gameURL.relativePath.UTF8String))
    {
        NSLog(@"Error loading ROM: %@", gameURL);
    }
}

- (void)stop
{
    NDS_FreeROM();
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
    NDS_beginProcessingInput();
    NDS_endProcessingInput();
    
    NDS_exec<false>();
    
    memcpy(self.videoRenderer.videoBuffer, GPU->GetDisplayInfo().masterNativeBuffer, 256 * 384 * 4);
    [self.videoRenderer processFrame];
    
    SPU_Emulate_user();
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
    //TODO: Copy automatically-saved game save to URL.
}

- (void)loadGameSaveFromURL:(NSURL *)URL
{
    //TODO: Load the game save at URL (and not just the automatically loaded game save).
}

#pragma mark - Save States -

- (void)saveSaveStateToURL:(NSURL *)URL
{
    savestate_save(URL.fileSystemRepresentation);
}

- (void)loadSaveStateFromURL:(NSURL *)URL
{
    savestate_load(URL.fileSystemRepresentation);
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

#pragma mark - Audio -

void DLTAUpdateAudio(s16 *buffer, u32 num_samples)
{
    [DSEmulatorBridge.sharedBridge.audioRenderer.audioBuffer writeBuffer:(uint8_t *)buffer size:num_samples * 4];
}

u32 DLTAGetAudioSpace()
{
    NSInteger availableBytes = DSEmulatorBridge.sharedBridge.audioRenderer.audioBuffer.availableBytesForWriting;
    
    u32 availableFrames = (u32)availableBytes / 4;
    return availableFrames;
}

#pragma mark - Getters/Setters -

- (NSTimeInterval)frameDuration
{
    return (1.0 / 60.0);
}

@end
