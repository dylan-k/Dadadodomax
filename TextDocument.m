/*
 TextDocument.m
 dadadodomax
 
 Created by endian on Mon Dec 08 2003.
 Copyright (c) 2003 Enigmarelle Development.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer as
 the first lines of this file unmodified.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED``AS IS'' AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
 NO EVENT SHALL ENIGMARELLE DEVELOPMENT BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/ 

#import "TextDocument.h"


@implementation TextDocument

- (NSString *)windowNibName 
{
    return @"TextDocument";
}

- (NSData *)dataRepresentationOfType:(NSString *)type 
{
    return (NSData *)dodoOutput;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type 
{
    return NO;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];
    
    [textView setString: dodoOutput];
    [self updateChangeCount:NSChangeDone];
}

- (void)setDodoOutput:(NSString *)newDodoOutput
{
    [newDodoOutput retain];
    [dodoOutput release];
    dodoOutput = newDodoOutput;
}

-(void)displayOutput
{
    [self showWindows];
}

@end
