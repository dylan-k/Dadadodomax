/*
 DodoDocument.m
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

#import "DodoDocument.h"
#import "HTMLDocument.h"
#import "TextDocument.h"

@implementation DodoDocument

- (id)init
{
    self = [super init];
    if (self) 
    {
	
	if (! (inputFiles = [[NSMutableArray alloc] initWithCapacity:0])    || 
            ! (outputDocuments = [[NSMutableArray alloc] initWithCapacity:0]) )
	{
	    [self release];
	    return nil;
	}
	
    }
    return self;
}

-(void)dealloc
{
    [dodoString release];
    [inputFiles release];
    [outputDocuments release];
}


- (NSString *)windowNibName
{
    return @"DodoDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    
    
    /* make sure we have something to work on before we enable the Generate button */
    [generateButton setEnabled:[self canGenerate]];
    
    /* tell the table view to accept files dragged in from Finder */
    [tableView registerForDraggedTypes:[NSArray arrayWithObject: NSFilenamesPboardType]];
    
    /* user double-clicks on table view item, we tell launch services to open the referenced file */
    [tableView setDoubleAction:@selector(openTableViewItem:)];
    
    [consoleView setFont: [NSFont userFixedPitchFontOfSize:9]];
    [consoleDrawer setLeadingOffset:5];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{    
    return [NSArchiver archivedDataWithRootObject:inputFiles];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    [inputFiles release];
    inputFiles = [NSUnarchiver unarchiveObjectWithData:data];
    [inputFiles retain];
    
    return YES;
}

-(IBAction)chooseFiles:(id)sender //CHANGES TABLEVIEW
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setAllowsMultipleSelection:YES];
    [oPanel beginSheetForDirectory:nil file:nil types:[NSArray arrayWithObjects:@"txt", @"text", @"html", @"htm", @"mbox", NSFileTypeForHFSTypeCode('TEXT'), nil] modalForWindow:docWindow modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:(NSDictionary *)[[NSDictionary  alloc] initWithObjectsAndKeys:@"appendOperation",@"operationType",NULL,NULL]];
}


-(IBAction)delete:(id)sender //CHANGES TABLEVIEW
{
    if (0 <= [tableView selectedRow])
    {
	[self removeFileAtIndex:[tableView selectedRow]];
	[self updateChangeCount:NSChangeDone];
    }
    
    if (0 == [self numberOfRowsInTableView:tableView]) //we're empty. don't let the user save the document or generate text
    {
	[self updateChangeCount:NSChangeCleared];
    }
    
    [generateButton setEnabled: [self canGenerate]]; //enable or disable the generate button as appropriate.
}

-(IBAction)replaceFile:(id)sender
{
    int selectedRow = [tableView selectedRow];
    
    if (0 <= selectedRow)
    {
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	NSString *fileToBeReplaced = [self objectInInputFilesAtIndex:selectedRow];
	
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel beginSheetForDirectory:[fileToBeReplaced stringByDeletingLastPathComponent] file:nil types:[NSArray arrayWithObjects:@"txt", @"text", @"html", @"htm", @"mbox", NSFileTypeForHFSTypeCode('TEXT'), nil] modalForWindow:docWindow modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:(NSDictionary *)[[NSDictionary alloc] initWithObjectsAndKeys:@"replaceOperation",@"operationType",[NSNumber numberWithInt:selectedRow],@"index",NULL,NULL]];
    }
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(NSDictionary *)contextInfo
{
    if (returnCode == NSOKButton)
    {
	if ([[contextInfo objectForKey:@"operationType"] isEqualToString:@"appendOperation"])
	{
	    [self appendFiles: [panel filenames]];
	}
	else if ([[contextInfo objectForKey:@"operationType"] isEqualToString:@"replaceOperation"])
	{
	    if ( nil != [contextInfo objectForKey:@"index"] )
	    {
		int index = [[contextInfo objectForKey:@"index"] intValue];
		[self replaceFileAtIndex:index withFile:[[panel filenames] objectAtIndex:0]];
	    }
	}
	
	[tableView reloadData];
	
	[self updateChangeCount:NSChangeDone];
	[generateButton setEnabled:[self canGenerate]];
	[contextInfo release];
    }
}

-(IBAction)generate:(id)sender
{
    id outputDocument;
    
    [progressIndicator startAnimation:nil];
    
    
    [[NSDocumentController sharedDocumentController] setShouldCreateUI:YES];
    if (YES == isHTML)
    {
	outputDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType: @"HTML Document" display:NO];
    }
    else
    {
	outputDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType: @"Text Document" display:NO];
    }
    
    [self performSelectorOnMainThread: @selector(doDadadodo:) withObject: outputDocument waitUntilDone: YES];
    [progressIndicator stopAnimation:nil];
}

-(void)doDadadodo:(id)outputDocument
{
    
    NSTask *dodo=[[NSTask alloc] init];
    NSPipe *output=[[NSPipe alloc] init];
    NSPipe *err=[[NSPipe alloc] init];
    NSFileHandle *outputHandle, *errorHandle;
    NSMutableArray *argArray = [NSMutableArray arrayWithObjects:@"-c", [sentenceCountField stringValue], nil];
    
    NSString *errString;
    
    if (YES == isHTML)
    {
	[argArray insertObject:@"-html" atIndex: 0];
    }
    
    NSArray *validFiles = [self validPathsFromArray:inputFiles];
    [argArray addObjectsFromArray: validFiles];
    
    [dodo setLaunchPath:[[NSBundle mainBundle] pathForResource:@"dadadodo" ofType:nil]];
    [dodo setArguments:argArray];
    [dodo setStandardOutput:output];
    [dodo setStandardError:err];
    
    outputHandle = [output fileHandleForReading];
    errorHandle = [err fileHandleForReading];
    
    [dodo launch];
    
    dodoString = [[NSString alloc] initWithData:[outputHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];  
    
    errString = [[NSString alloc] initWithData:[errorHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
    
    [consoleView setString: errString];    
    
    [outputDocument setDodoOutput:dodoString];
    
    [outputDocument displayOutput];
    
    [output release];
    [err release];
    [dodo release];
}

-(IBAction)setHTML:(id)sender
{
    isHTML = [sender intValue];
}

-(BOOL)validatePathArray:(NSArray *)paths
{
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSEnumerator *pathEnumerator = [paths objectEnumerator];
    NSString *pathString;
    
    int invalidCount = 0;
    
    while (pathString = [pathEnumerator nextObject])
    {
	if (![fManager isReadableFileAtPath: pathString])
	{
	    invalidCount++;
	}
    }
    
    return !(invalidCount == [paths count]);
}

-(NSArray *)validPathsFromArray:(NSArray *)anArray
{
    NSMutableArray *outArray = [[NSMutableArray alloc] init];
    NSEnumerator *inArrayEnumerator = [anArray objectEnumerator];
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSString *eachString;
    
    while (eachString = [inArrayEnumerator nextObject])
    {
	if ([fManager isReadableFileAtPath: eachString])
	{
	    [outArray addObject: eachString];
	}
    }
    
    return [[outArray copy] autorelease];
}

-(BOOL)canGenerate
{
    return [self validatePathArray: inputFiles];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    if ([anItem action] == @selector(generate:))
    {
	return [self canGenerate];
    }
    
    if ([anItem action] == @selector(delete:))
    {
	return (0 <= [tableView selectedRow]);
    }
    
    if ([anItem action] == @selector(replaceFile:))
    {
	return (0 <= [tableView selectedRow]);
    }
    
    if ( ([anItem action] == @selector(printDocument:)) || ([anItem action] == @selector(runPageLayout:)) )
    {
	return NO;
    }
    
    if ([anItem action] == @selector(toggleConsoleDrawer:))
    {
	
	if ( ([consoleDrawer state] == NSDrawerOpenState) || ([consoleDrawer state] == NSDrawerOpeningState) )
	{
	    [anItem setTitle:@"Hide Console"];
	}
	else
	{
	    [anItem setTitle:@"Show Console"];
	}
    }
    
    
    return [super validateMenuItem:(NSMenuItem *)anItem];
}

-(IBAction)toggleConsoleDrawer:(id)sender
{
    [consoleDrawer toggle:nil];
}

#pragma mark TABLEVIEW SUPPORT

-(int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [inputFiles count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    int row = [[aNotification object] selectedRow];
    
    if (row < 0)
    {
	[pathField setStringValue: @""];
	return;
    }
    
    [pathField setStringValue: [[inputFiles objectAtIndex: row] stringByAbbreviatingWithTildeInPath]];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    BOOL fileFound;
    
    fileFound = [[NSFileManager defaultManager] isReadableFileAtPath: [inputFiles objectAtIndex: rowIndex]];
    
    if ( NO == fileFound )
    {    
	NSColor *txtColor = [NSColor redColor];
	NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys: txtColor, NSForegroundColorAttributeName, nil];
	NSAttributedString *attrStr = [[[NSAttributedString alloc]
        initWithString:[aCell stringValue] attributes:txtDict] autorelease];
	[aCell setAttributedStringValue:attrStr];
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{    
    return [[inputFiles objectAtIndex: row] lastPathComponent];
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op 
{
    NSEnumerator *typesEnumerator;
    BOOL hasNonTextFile = NO;
    
    if (typesEnumerator = [[[info draggingPasteboard] propertyListForType: NSFilenamesPboardType] objectEnumerator])
    {
	NSString *eachString;
	NSDocumentController *docController = [NSDocumentController sharedDocumentController];
	NSArray *goodTypes = [[[TextDocument class] readableTypes] arrayByAddingObjectsFromArray:[[HTMLDocument class] readableTypes]];
	
	//validate dragged files are all text or html files.
	while ( eachString = [typesEnumerator nextObject] )
	{ 
	    NSString *thisExtension = [docController typeFromFileExtension:[eachString pathExtension]];
	    NSString *thisHFSType = [docController typeFromFileExtension:NSHFSTypeOfFile(eachString)];
	    
	    if ( (![goodTypes containsObject: thisExtension]) && (![goodTypes containsObject: thisHFSType]) )
	    {
		hasNonTextFile = YES;
	    }
	}
    }
    
    if (NO == hasNonTextFile)
    {
	return (NSDragOperationCopy);
    }
    else
    {
	return NSDragOperationNone;
    }
}

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op //CHANGES TABLEVIEW
{
    NSPasteboard *pboard = [info draggingPasteboard];
    
    if (op == NSTableViewDropAbove) 
    {
	[inputFiles replaceObjectsInRange:NSMakeRange(row, 0) withObjectsFromArray:[pboard propertyListForType: NSFilenamesPboardType]];
    } 
    else 
    {
	[inputFiles replaceObjectsInRange:NSMakeRange(row+1, 0) withObjectsFromArray:[pboard propertyListForType: NSFilenamesPboardType]];
    }
    
    [generateButton setEnabled:[self canGenerate]];
    
    [self updateChangeCount:NSChangeDone];
    
    [tableView reloadData];
    return YES;
}

-(void)openTableViewItem:(id)sender
{
    if (![[NSWorkspace sharedWorkspace] openFile: [inputFiles objectAtIndex:[sender selectedRow]]]) NSBeep();
}

-(void)addFile:(NSString *)aPath atIndex:(unsigned int)anIndex
{
    [self insertObject: aPath inInputFilesAtIndex: anIndex];
    [tableView reloadData];
}

-(void)removeFileAtIndex:(unsigned int)anIndex
{    
    [self removeObjectFromInputFilesAtIndex:anIndex];
    [tableView reloadData];
}

-(void)replaceFileAtIndex:(unsigned int)index withFile:(NSString *)aPath
{    
    [self replaceObjectInInputFilesAtIndex: (unsigned int)index withObject: aPath];
    [pathField setStringValue: [aPath stringByAbbreviatingWithTildeInPath]];
    [tableView reloadData];
}

-(void)appendFiles:(NSArray *)someFiles
{
    [inputFiles addObjectsFromArray:someFiles];
    [tableView reloadData];
}

-(void)appendFile:(NSString *)aPath
{
    [inputFiles addObject:aPath];
    [tableView reloadData];
}

#pragma mark TABLEVIEW DATASOURCE STUFF

///////  inputFiles  ///////

- (unsigned int) countOfInputFiles 
{
    return [[self inputFiles] count];
}

- (id) objectInInputFilesAtIndex: (unsigned int)index 
{
    return [[self inputFiles] objectAtIndex: index];
}

- (void) insertObject: (id)anObject inInputFilesAtIndex: (unsigned int)index 
{
    [[self inputFiles] insertObject: anObject atIndex: index];
}

- (void) removeObjectFromInputFilesAtIndex: (unsigned int)index 
{
    [[self inputFiles] removeObjectAtIndex: index];
}

- (void) replaceObjectInInputFilesAtIndex: (unsigned int)index withObject: (id)anObject 
{
    [[self inputFiles] replaceObjectAtIndex: index withObject: anObject];
}

// ===========================================================
// - inputFiles:
// ===========================================================
- (NSMutableArray *) inputFiles
{
    return [[inputFiles retain] autorelease]; 
}

// ===========================================================
// - setInputFiles:
// ===========================================================
- (void) setInputFiles: (NSMutableArray *) anInputFiles
{
    if (inputFiles != anInputFiles) {
        [inputFiles release];
        inputFiles = [anInputFiles copy];
    }
}

@end
