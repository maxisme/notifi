//
//  Constants.m
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 04/01/2019.
//  Copyright © 2020 Maximilian Mitchell. All rights reserved.
//

#import "Constants.h"

#ifdef DEBUG
    NSString* const BackendURL = @"http://127.0.0.1:8080";

    NSString* const CredentialsRef = @"credentials DEBUG";
    NSString* const CredentialKeyRef = @"credential_key DEBUG";

#else
    NSString* const BackendURL = @"https://s.notifi.it";

    NSString* const CredentialsRef = @"credentials";
    NSString* const CredentialKeyRef = @"credential_key";
#endif
