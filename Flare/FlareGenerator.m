//
//  FlareGenerator.m
//  Flare
//
//  Created by Zakk Hoyt on 10/17/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "FlareGenerator.h"

static NSString *kNameKey = @"name";
static NSString *kSizeKey = @"size";
static NSString *kChildrenKey = @"children";
@interface FlareGenerator ()
@property (strong) NSFileManager *fileManager;
@property (strong) NSMutableDictionary *fileValues;
@property (strong) NSMutableDictionary *flare;
@end


@implementation FlareGenerator

-(id)init{
    self = [super init];
    if(self){
        _fileManager = [[NSFileManager alloc] init];
        _fileValues = [@{}mutableCopy];
        _flare = [@{}mutableCopy];
    }
    return self;
}

-(void)test{
    
    NSMutableDictionary *child1 = [@{}mutableCopy];
    [child1 setObject:@"child1" forKey:kNameKey];
    [child1 setObject:@(2) forKey:kSizeKey];
    
    NSMutableDictionary *child2 = [@{}mutableCopy];
    [child2 setObject:@"child2" forKey:kNameKey];
    [child2 setObject:@(22) forKey:kSizeKey];
    
//    NSMutableDictionary *root = [@{}mutableCopy];
//    [root setObject:@"root" forKey:kNameKey];
//    [child1 setObject:@(2) forKey:kSizeKey];
    
    NSArray *children = @[child1, child2];
    [self.flare setObject:@"root" forKey:kNameKey];
    [self.flare setObject:children forKey:kChildrenKey];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.flare
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json string; %@", jsonString);
        NSLog(@"");
    }
    
    
    
}

-(void)scanDirectoriesUnder:(NSURL*)url processStartingFromFile:(NSURL*)file{
    [self indexFilesAtURL:url];
    NSLog(@"Finished indexing. Found %ld files: \n %@ %@", self.fileValues.count, self.fileValues.allKeys, self.fileValues.allValues);
    
    [self processFilesStartingWith:file];
}


-(void)processFiles{
    // If the m file has private imports
    
    // Iterate files
    for(NSURL *url in self.fileValues.allValues){
        [self processFileAtURL:url];
    }
    
}

-(void)processFilesStartingWith:(NSURL*)file{
    NSError *error;
    NSString *sourceString = [NSString stringWithContentsOfURL:file
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if(error){
        // TODO
    }
    
    NSArray *lines = [sourceString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    for(NSString *line in lines){
        if([line hasPrefix:@"#import"] ||
           [line hasPrefix:@"#include"]){
            NSArray *chunks = [line componentsSeparatedByString: @"\""];
            if(chunks.count > 1){
                NSString *key = chunks[1];
                NSLog(@"file %@ includes %@", file, key);
            }
        }
    }
    
}

-(void)processFileAtURL:(NSURL*)url{
//    NSLog(@"Processing file %@", url.absoluteString);
    NSError *error;
    NSString *sourceString = [NSString stringWithContentsOfURL:url
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if(error){
        // TODO
    }
    
    NSArray *lines = [sourceString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    for(NSString *line in lines){
        if([line hasPrefix:@"#import"] ||
           [line hasPrefix:@"#include"]){
            NSArray *chunks = [line componentsSeparatedByString: @"\""];
            if(chunks.count > 1){
                NSString *key = chunks[1];
                NSLog(@"file %@ includes %@", url, key);
            }
        }
    }
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
