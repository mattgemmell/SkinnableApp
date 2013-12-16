//
//  AppController.h
//  SkinnableApp
//
//  Created by Matt Gemmell on 24/02/2008.
//  Copyright 2008 Magic Aubergine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppController : NSObject {
    IBOutlet WebView *webView;
    IBOutlet NSPopUpButton *themeChooser;
    IBOutlet NSTextField *titleText;
}

- (IBAction)changeTheme:(id)sender;
- (IBAction)addContent:(id)sender;
- (IBAction)setTitle:(id)sender;

// This method is called from JavaScript on the web page.
- (void)showMessage:(NSString *)message;

@end
