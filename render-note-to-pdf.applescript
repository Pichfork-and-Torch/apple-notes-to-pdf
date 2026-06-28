-- render-note-to-pdf.applescript
-- Helper for export-apple-notes.sh (v3)
-- Renders a single note's HTML body (or HTML fragment) to a PDF file
-- using NSAttributedString + printing to PDF. No UI scripting required.
--
-- Usage (from shell):
--   osascript render-note-to-pdf.applescript /tmp/note-body.html /tmp/output.pdf
--
-- The input file should contain the rich HTML content from Notes (body of note).
-- Output is a standard PDF (multi-page if the content is long).

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"
use framework "AppKit"

-- Entry point
on run argv
	if (count of argv) < 2 then
		error "Usage: osascript render-note-to-pdf.applescript INPUT_HTML_PATH OUTPUT_PDF_PATH"
	end if
	
	set inputHTMLPath to (item 1 of argv) as text
	set outputPDFPath to (item 2 of argv) as text
	
	-- Read the HTML content safely via shell (avoids various coercion issues in ASObjC context)
	set htmlString to do shell script "cat " & quoted form of inputHTMLPath
	
	-- Convert to NSAttributedString via HTML import (this brings in basic styling + images when data: URLs are present)
	set theNSString to current application's NSString's stringWithString:htmlString
	set theData to theNSString's dataUsingEncoding:(current application's NSUTF8StringEncoding)
	set styledText to (current application's NSAttributedString's alloc()'s initWithHTML:theData documentAttributes:(missing value))
	
	-- Render to PDF using Shane Stanley's excellent print-to-PDF handler (adapted)
	my saveStyledText:styledText asPDFToFile:outputPDFPath
end run


-- ======================  HANDLERS  ======================

on saveStyledText:styledText asPDFToFile:newPath
	-- classes / constants
	set NSAutoPagination to 0
	set NSClipPagination to 2
	set NSPrintJobSavingURL to current application's NSPrintJobSavingURL
	set NSPrintOperation to current application's NSPrintOperation
	set NSPrintSaveJob to current application's NSPrintSaveJob
	set NSURL to current application's NSURL
	set NSPrintInfo to current application's NSPrintInfo
	set NSTextView to current application's NSTextView
	set NSDictionary to current application's NSDictionary
	set NSThread to current application's NSThread
	
	-- create print info configured for file output
	set destURL to NSURL's fileURLWithPath:newPath
	set printInfo to NSPrintInfo's alloc()'s initWithDictionary:(NSDictionary's dictionaryWithObject:destURL forKey:NSPrintJobSavingURL)
	printInfo's setJobDisposition:NSPrintSaveJob
	printInfo's setHorizontalPagination:NSClipPagination
	printInfo's setVerticalPagination:NSAutoPagination
	printInfo's setHorizontallyCentered:false
	printInfo's setVerticallyCentered:false
	
	-- page geometry
	set pageSize to printInfo's paperSize()
	set theLeft to printInfo's leftMargin()
	set theRight to printInfo's rightMargin()
	set theTop to printInfo's topMargin()
	
	-- create a tall text view that will auto-paginate
	set theView to NSTextView's alloc()'s initWithFrame:{{0, 0}, {(pageSize's width) - theLeft - theRight, 3.0E+38}}
	theView's setHorizontallyResizable:false
	theView's textStorage()'s setAttributedString:styledText
	
	-- sizeToFit must happen on main thread
	if NSThread's isMainThread() then
		theView's sizeToFit()
	else
		theView's performSelectorOnMainThread:"sizeToFit" withObject:(missing value) waitUntilDone:true
	end if
	
	-- run the print operation (saves directly to the URL we set)
	set printOp to NSPrintOperation's printOperationWithView:theView printInfo:printInfo
	printOp's setShowsPrintPanel:false
	printOp's setShowsProgressPanel:false
	
	if NSThread's isMainThread() then
		printOp's runOperation()
	else
		my performSelectorOnMainThread:"runPrintOperation:" withObject:printOp waitUntilDone:true
	end if
end saveStyledText:asPDFToFile:

on runPrintOperation:printOp -- called on main thread if needed
	printOp's runOperation()
end runPrintOperation:
