/*
 DodoDocument.h
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


#import <Cocoa/Cocoa.h>

@interface DodoDocument : NSDocument
{
    IBOutlet NSButton *chooseFilesButton;
    IBOutlet NSTableView *tableView;
    IBOutlet NSTextField *sentenceCountField;
    IBOutlet NSButton *htmlSwitch;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSButton *generateButton;
    IBOutlet NSTextField *pathField;
    IBOutlet NSWindow *docWindow;
    IBOutlet NSDrawer *consoleDrawer;
    IBOutlet NSTextView *consoleView;
    
    BOOL isHTML;
    NSString *dodoString;
    NSMutableArray *inputFiles;
    
    NSMutableArray *outputDocuments;
}

-(IBAction)chooseFiles:(id)sender;
-(IBAction)replaceFile:(id)sender;
-(IBAction)generate:(id)sender;
-(IBAction)setHTML:(id)sender;
-(IBAction)toggleConsoleDrawer:(id)sender;

-(void)doDadadodo:(id)outputDocument;
-(BOOL)validatePathArray:(NSArray *)paths;
-(NSArray *)validPathsFromArray:(NSArray *)anArray;
-(BOOL)canGenerate;
-(void)addFile:(NSString *)aPath atIndex:(unsigned int)anIndex;
-(void)removeFileAtIndex:(unsigned int)anIndex;
-(void)appendFiles:(NSArray *)someFiles;
-(void)appendFile:(NSString *)aPath;
-(void)replaceFileAtIndex:(unsigned int)index withFile:(NSString *)aPath;

    ///////  inputFiles  ///////

- (NSMutableArray *) inputFiles;
- (void) setInputFiles: (NSMutableArray *) anInputFiles;

- (unsigned int) countOfInputFiles;
- (id) objectInInputFilesAtIndex: (unsigned int)index;
- (void) insertObject: (id)anObject inInputFilesAtIndex: (unsigned int)index;
- (void) removeObjectFromInputFilesAtIndex: (unsigned int)index;
- (void) replaceObjectInInputFilesAtIndex: (unsigned int)index withObject: (id)anObject;

@end
