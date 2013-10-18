//
//  FlareGenerator.h
//  Flare
//
//  Created by Zakk Hoyt on 10/17/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlareGenerator : NSObject
-(void)scanDirectoriesUnder:(NSURL*)url processStartingFromFile:(NSURL*)file;
@end
