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

#import <UIKit/UIKit.h>
#import "lcp/content_module_lcp.h"

@interface CredentialController : NSObject <UIAlertViewDelegate>{
    
}
- (void)openDlgFromCredentialRequest:(NSValue*)request;

@end