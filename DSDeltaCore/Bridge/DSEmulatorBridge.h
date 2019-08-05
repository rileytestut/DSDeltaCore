//
//  DSEmulatorBridge.h
//  DSDeltaCore
//
//  Created by Riley Testut on 8/2/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DeltaCore/DeltaCore.h>
#import <DeltaCore/DeltaCore-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSEmulatorBridge : NSObject <DLTAEmulatorBridging>

@property (class, nonatomic, readonly) DSEmulatorBridge *sharedBridge;

@end

NS_ASSUME_NONNULL_END
