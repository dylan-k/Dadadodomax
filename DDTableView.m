/*
 DDTableView.m
 dadadodomax
 
 Code by Timothy Hatcher, from http://www.cocoadev.com/index.pl?RightClickSelectInTableView 
*/ 

#import "DDTableView.h"

@implementation DDTableView

- (NSMenu *) menuForEvent:(NSEvent *) event 
{
    NSPoint where;
    int row = -1, col = -1;
    
    where = [self convertPoint:[event locationInWindow] fromView:nil];
    row = [self rowAtPoint:where];
    col = [self columnAtPoint:where];
    
    if( row >= 0 ) 
    {
	NSTableColumn *column = nil;
	if( col >= 0 ) column = [[self tableColumns] objectAtIndex:col];
	
	if( [[self delegate] respondsToSelector:@selector( tableView:shouldSelectRow: )] ) 
	{
	    if( [[self delegate] tableView:self shouldSelectRow:row] )
		[self selectRow:row byExtendingSelection:NO];
	} else [self selectRow:row byExtendingSelection:NO];
	
	if( [[self dataSource] respondsToSelector:@selector( tableView:menuForTableColumn:row: )] )
	    return [[self dataSource] tableView:self menuForTableColumn:column row:row];
	else return [self menu];
    }
    
    [self deselectAll:nil];
    return [self menu];
}

@end
