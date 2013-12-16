//
//  AppController.m
//  SkinnableApp
//
//  Created by Matt Gemmell on 24/02/2008.
//  Copyright 2008 Magic Aubergine. All rights reserved.
//

#import "AppController.h"


@implementation AppController


#pragma mark Setup


- (void)awakeFromNib
{
    // Set us up as the delegate of the webView for relevant events.
    [webView setDrawsBackground:NO];
    [webView setUIDelegate:self];
    [webView setFrameLoadDelegate:self];
    [webView setEditingDelegate:self];
    
    // Configure webView to let JavaScript talk to this object.
    [[webView windowScriptObject] setValue:self forKey:@"AppController"]; // can be any unique name you want
    /*
     Notes: 
        1. In JavaScript, you can now talk to this object using "window.AppController".
     
        2. You must explicitly allow methods to be called from JavaScript;
            See the +isSelectorExcludedFromWebScript: method below for an example.
     
        3. The method on this class which we call from JavaScript is -showMessage:
            To call it from JavaScript, we use window.AppController.showMessage_()  <-- NOTE colon becomes underscore!
            For more on method-name translation, see:
            http://developer.apple.com/documentation/AppleApplications/Conceptual/SafariJSProgTopics/Tasks/ObjCFromJavaScript.html#
     */
    
    // Load the HTML content.
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    NSString *htmlPath = [resourcesPath stringByAppendingString:@"/index.html"];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    
    // Set up the themes chooser.
    [themeChooser removeAllItems];
    NSArray *themes = [[NSBundle mainBundle] pathsForResourcesOfType:@"css" inDirectory:nil];
    for (NSString *theme in themes) {
        // Get theme name without file-extension
        NSString *themeName = [theme lastPathComponent];
        NSRange dotRange = [themeName rangeOfString:@"."];
        if (dotRange.location != NSNotFound) {
            themeName = [themeName substringToIndex:dotRange.location];
        }
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:themeName 
                                                          action:@selector(changeTheme:) 
                                                   keyEquivalent:@""];
        [menuItem setTarget:self];
        [menuItem setRepresentedObject:[theme lastPathComponent]];
        if ([themeName isEqualToString:@"Default"]) {
            [menuItem setState:NSOnState];
        }
        [[themeChooser menu] addItem:menuItem];
        [menuItem release];
    }
}


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    // For security, you must explicitly allow a selector to be called from JavaScript.
    
    if (aSelector == @selector(showMessage:)) {
        return NO; // i.e. showMessage: is NOT _excluded_ from scripting, so it can be called.
    }
    
    return YES; // disallow everything else
}


#pragma mark WebView delegate methods


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame 
{
    // This is a WebView Frame Load Delegate method.
    
    // The HTML document just loaded, so we'll grab the current content of 
    // the 'contentTitle' H1 tag, and put it in the titleText NSTextField.
    // This code shows you how to get a value from the HTML document.
    
    DOMDocument *myDOMDocument = [[webView mainFrame] DOMDocument];
    DOMElement *contentTitle = [myDOMDocument getElementById:@"contentTitle"];
    [titleText setStringValue:[[contentTitle firstChild] nodeValue]];
}


- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element 
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    // This is a WebView UI Delegate method.
    
    return nil; // disable contextual menu for the webView
}


- (BOOL)webView:(WebView *)webView shouldChangeSelectedDOMRange:(DOMRange *)currentRange 
     toDOMRange:(DOMRange *)proposedRange affinity:(NSSelectionAffinity)selectionAffinity 
 stillSelecting:(BOOL)flag
{
    // This is a WebView Editing Delegate method.
    
    return NO; // prevent selection of content
}


#pragma mark IBActions


- (IBAction)changeTheme:(id)sender
{
    // The user just chose a theme in the NSPopUpButton, so we replace the HTML
    // document's CSS file using JavaScript. This is a simple way to support 
    // dynamically loaded CSS themes.
    
    WebScriptObject *scriptObject = [webView windowScriptObject];
    NSString *theme = [[themeChooser selectedItem] representedObject];
    NSString *script = [NSString stringWithFormat:@"document.getElementById('ss').href = '%@'", theme];
    [scriptObject evaluateWebScript:script];
}


- (IBAction)addContent:(id)sender
{
    // The user just clicked the Add Content NSButton, so we'll add a new P tag 
    // to the HTML, with some default content. This shows you how to add content 
    // into an HTML document without reloading the page.
    
    DOMDocument *myDOMDocument = [[webView mainFrame] DOMDocument];
    DOMElement *paraBlock = [myDOMDocument getElementById:@"main_content"];
    DOMElement *newPara = [myDOMDocument createElement:@"p"];
    
    DOMText *newText = [myDOMDocument createTextNode:@"Some new content"];
    [newPara appendChild:newText];
    [paraBlock appendChild:newPara];
}


- (IBAction)setTitle:(id)sender {
    // The user clicked the Set Title button, so we'll take whatever text is in 
    // the titleText NSTextField and replace the current content of the 'contentTitle' 
    // H1 tag in the HTML with the new text. This shows you how to replace some HTML 
    // content with new content.
    
    DOMDocument *myDOMDocument = [[webView mainFrame] DOMDocument];
    DOMText *newText = [myDOMDocument createTextNode:[titleText stringValue]];
    
    DOMElement *contentTitle = [myDOMDocument getElementById:@"contentTitle"];
    [contentTitle replaceChild:newText oldChild:[contentTitle firstChild]];
}


- (void)showMessage:(NSString *)message
{
    // This method is called from the JavaScript "onClick" handler of the INPUT element 
    // in the HTML. This shows you how to have HTML form elements call Cocoa methods.
    
    NSRunAlertPanel(@"Message from JavaScript", message, nil, nil, nil);
}


@end
