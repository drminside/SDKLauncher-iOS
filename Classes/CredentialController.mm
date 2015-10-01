//
//  LOXCredentialController.mm
//  LauncherOSX
//
//  Created by Fasoo.com Development Team6 on 2015-09-15.
//  ( M.N. Kim)
//
//  Copyright (c) 2015 The Readium Foundation and contributors. All rights reserved.
//
//  The Readium SDK is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//

#include <ePub3/initialization.h>
#import <Foundation/Foundation.h>
#import "CredentialController.h"

//#include "LCP/authentication_handler.h"
#include <ePub3/utilities/error_handler.h>

#import "AppDelegate.h"
#import "ContainerController.h"
#include <future>
@implementation CredentialController{
    
    ePub3::CredentialRequest *reqPtr;
    NSMutableDictionary *credentialDictionary;
    bool waitPassword;
}

- (void)openDlgFromCredentialRequest:(NSValue*)request
{
    reqPtr = (ePub3::CredentialRequest*)[request pointerValue];
    credentialDictionary = [[NSMutableDictionary alloc] init];

    std::size_t listNum = reqPtr->GetComponentCount();
    NSString* title = [NSString stringWithUTF8String:reqPtr->GetTitle().c_str()];
    NSString *message = [NSString stringWithUTF8String:reqPtr->GetMessage().c_str()];
    NSString* OKBtn = @"OK";
    
    UIAlertView* alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:OKBtn];
    [alert setTitle:title];
    [alert setMessage:message];
    [alert setDelegate:self];
    
    for(int i=2; i<listNum; i++){
        switch ((ePub3::CredentialRequest::Type)reqPtr->GetItemType(i)) {
            case ePub3::CredentialRequest::Type::Message:
            {
                break;
            }
            case (ePub3::CredentialRequest::Type::TextInput):
            {
                NSString *inputTitle = [NSString stringWithUTF8String:(reqPtr->GetItemTitle(i).c_str())];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                break;
            }
            case (ePub3::CredentialRequest::Type::MaskedInput):
            {
                NSString *inputTitle = [NSString stringWithUTF8String:(reqPtr->GetItemTitle(i).c_str())];
                [credentialDictionary setObject:[NSNumber numberWithInt:i] forKey:OKBtn];
                alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                break;
            }
            case (ePub3::CredentialRequest::Type::Button):
            {
                NSString *buttonTitle = [NSString stringWithUTF8String:(reqPtr->GetItemTitle(i).c_str())];
                [credentialDictionary setObject:[NSNumber numberWithInt:i] forKey:buttonTitle];
                if([buttonTitle isEqualToString:@"Forgot password"])
                    continue;
                [alert addButtonWithTitle:buttonTitle];
                break;
            }
            default:
                break;
        }
        
    }
    
    [self performSelectorOnMainThread:@selector(RunOnMainThreadUI:) withObject:alert waitUntilDone:YES];
    
    waitPassword = true;
    while (waitPassword) {
        [NSThread sleepForTimeInterval:0.1];
    }
}

-(void)RunOnMainThreadUI:(UIAlertView*)alert
{
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    if([buttonTitle isEqualToString:@"OK"])
    {
        NSNumber* idx = [credentialDictionary objectForKey:buttonTitle];
        NSObject* obj = [alertView textFieldAtIndex:0];
        if([obj isKindOfClass:[UITextField class]])
        {
            UITextField* textViewID = (UITextField*)obj;
            NSString * password = textViewID.text;
            reqPtr->SetCredentialItem(ePub3::string(reqPtr->GetItemTitle([idx intValue]).c_str()), ePub3::string([password UTF8String]));
        }
    }
    else
    {
        [NSThread detachNewThreadSelector:@selector(buttonAction:) toTarget:self withObject:buttonTitle];
    }
    reqPtr->SignalCompletion();
    waitPassword = false;
}

-(void)buttonAction:(NSString*)buttonTitle
{
    NSNumber* idx = [credentialDictionary objectForKey:buttonTitle];
    reqPtr->SetPressedButtonIndex([idx intValue]);
    auto t = reqPtr->GetButtonHandler([idx intValue]);
    if(t != nullptr) {
        t(nullptr, [idx intValue]);
    }
}

@end
