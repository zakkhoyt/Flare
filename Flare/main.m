//
//  main.m
//  Flare
//
//  Created by Zakk Hoyt on 10/17/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlareGenerator.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSURL *root = [NSURL URLWithString:@"/Users/zakkhoyt/Code/repositories/vww/Theremin/Theremin"];
        
        FlareGenerator *flare = [[FlareGenerator alloc]init];
        [flare startAtURL:root];
    }
    return 0;
}

