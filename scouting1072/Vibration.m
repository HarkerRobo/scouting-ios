//
//  Vibration.m
//  scouting1072
//
//  Created by Aydin Tiritoglu.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);
void AudioServicesStopSystemSound(SystemSoundID inSystemSoundID);


void vibrate() {
    NSMutableArray* arr = [NSMutableArray array];
    [arr addObject:@YES];
    [arr addObject:@100];
    
    [arr addObject:@NO];
    [arr addObject:@10];
    
    NSDictionary *dict = @{@"Intensity": @1,@"VibePattern": arr};
    AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate,nil,dict);
}
