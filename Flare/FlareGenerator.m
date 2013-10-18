//
//  FlareGenerator.m
//  Flare
//
//  Created by Zakk Hoyt on 10/17/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "FlareGenerator.h"

@interface FlareGenerator ()
@property (strong) NSFileManager *fileManager;
@property (strong) NSMutableDictionary *fileValues;
@end


@implementation FlareGenerator

-(id)init{
    self = [super init];
    if(self){
        _fileManager = [[NSFileManager alloc] init];
        _fileValues = [@{}mutableCopy];
    }
    return self;
}

-(void)startAtURL:(NSURL*)url{
    [self indexFilesAtURL:url];
    NSLog(@"Finished indexing. Found %ld files: \n %@ %@", self.fileValues.count, self.fileValues.allKeys, self.fileValues.allValues);
    
    [self processFiles];
}


-(void)processFiles{
    // If the m file has private imports
    
    
}

-(void)indexFilesAtURL:(NSURL*)url{
    
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [self.fileManager
                                         enumeratorAtURL:url
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    for (NSURL *subURL in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if(![subURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]){
            NSLog(@"Could not determine if %@ is a direcory", subURL);
        }
        
        
        if([isDirectory boolValue]){
            NSLog(@"Found subdir: %@", subURL.absoluteString);
            [self indexFilesAtURL:subURL];
        }
        else{
            // Is this a .h or .m or .mm file?
            NSString *pathExtension = [subURL pathExtension];
            if([pathExtension isEqualToString:@"h"] ||
               [pathExtension isEqualToString:@"m"] ||
               [pathExtension isEqualToString:@"mm"]){
                // Add to data
                NSLog(@"Adding file to set: %@", subURL.absoluteString);
                //[self.fileSet addObject:subURL];
                NSString *localizedName;
                NSError *error;
                [subURL getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:&error];
                
                [self.fileValues setObject:subURL forKey:localizedName];
                
            }
        }
    }
}

@end
