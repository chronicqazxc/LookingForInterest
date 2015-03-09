//
//  FacebookController.m
//  LookingForInterest
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "FacebookController.h"

@interface FacebookController()
@property (strong, nonatomic) NSMutableDictionary *paramsDic;
@end

@implementation FacebookController
- (void)shareWithLink:(NSString *)link name:(NSString *)name caption:(NSString *)caption description:(NSString *)description picture:(NSString *)picture message:(NSString *)message{
    // Check if the Facebook app is installed and we can present the share dialog
    
    // If the Facebook app is installed and we can present the share dialog
//    FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:[NSURL URLWithString:link] name:name caption:caption description:description picture:[NSURL URLWithString:picture]];
//
//    if ([FBDialogs canPresentShareDialogWithParams:params]) {
//        // Present the share dialog
//        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//            if(error) {
//                // An error occurred, we need to handle the error
//                // See: https://developers.facebook.com/docs/ios/errors
//                NSLog(@"Error publishing story: %@", error.description);
//            } else {
//                // Success
//                NSLog(@"result %@", results);
//            }
//        }];
//    } else {
//        // Present the feed dialog
//        NSMutableDictionary *params = [NSMutableDictionary dictionary];
//        [params setObject:name forKey:@"name"];
//        [params setObject:caption forKey:@"caption"];
//        [params setObject:description forKey:@"description"];
//        [params setObject:link forKey:@"link"];
//        [params setObject:picture forKey:@"picture"];
//        [params setObject:message forKey:@"message"];
//        [self feedDialogWithDic:params];
//    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:name forKey:@"name"];
    [params setObject:caption forKey:@"caption"];
    [params setObject:description forKey:@"description"];
    [params setObject:link forKey:@"link"];
    [params setObject:picture forKey:@"picture"];
    [params setObject:message forKey:@"message"];
    [self feedDialogWithDic:params];
}

- (void)feedDialogWithDic:(NSMutableDictionary *)params {
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                      // An error occurred, we need to handle the error
                                                      // See: https://developers.facebook.com/docs/ios/errors
                                                      NSLog(@"Error publishing story: %@", error.description);
                                                  } else {
                                                      if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // User cancelled.
                                                          NSLog(@"User cancelled.");
                                                      } else {
                                                          // Handle the publish feed callback
                                                          NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                          
                                                          if (![urlParams valueForKey:@"post_id"]) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                              
                                                          } else {
                                                              // User clicked the Share button
                                                              NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                              NSLog(@"result %@", result);
                                                              if (self.delegate && [self.delegate respondsToSelector:@selector(publishSuccess:)]) {
                                                                  [self.delegate publishSuccess:[urlParams valueForKey:@"post_id"]];
                                                              }
                                                          }
                                                      }
                                                  }
                                              }];
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)shareByAPICallWithName:(NSString *)name caption:(NSString *)caption description:(NSString *)description link:(NSString *)link picture:(NSString *)picture message:(NSString *)message privacy:(NSString *)privacy{
    [self checkForPermission:@"publish_actions"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   name, @"name",
                                   caption, @"caption",
                                   description, @"description",
                                   link, @"link",
                                   picture, @"picture",
                                   message, @"message",
                                   nil];
    self.paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
}

- (void)shareByAPICallEnsureHavePermission {
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:self.paramsDic
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"%@", error.description);
                              }
                          }];
}

- (void)checkForPermission:(NSString *)permission {
    //publish_actions
    // Check for publish permissions
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  // Walk the list of permissions, see if publish_actions has been granted
                                  NSArray *permissions = (NSArray *)[result data];
                                  BOOL publishActionsSet = FALSE;
                                  for (NSDictionary *perm in permissions) {
                                      if ([[perm objectForKey:@"permission"] isEqualToString:permission] &&
                                          [[perm objectForKey:@"status"] isEqualToString:@"granted"]) {
                                          publishActionsSet = TRUE;
                                          NSLog(@"publish_actions granted.");
                                          break;
                                      }
                                  }
                                  if (!publishActionsSet){
                                      // Permissions not found, ask for publish_actions
                                      [self requestMorePermission:permission];
                                      
                                  } else {
                                      // Publish permissions found, publish story
                                      [self shareByAPICallEnsureHavePermission];
                                  }
                                  
                              } else {
                                  // There was an error, handle it. See https://developers.facebook.com/docs/ios/errors/
                                  [self handleRequestPermissionError:error];
                              }
                          }];
}

- (void)requestMorePermission:(NSString *)permission {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:permission]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            __block NSString *alertText;
                                            __block NSString *alertTitle;
                                            if (!error) {
                                                if ([FBSession.activeSession.permissions
                                                     indexOfObject:@"publish_actions"] == NSNotFound){
                                                    // Permission not granted, tell the user we will not publish
                                                    alertTitle = @"Permission not granted";
                                                    alertText = @"Your action will not be published to Facebook.";
                                                    if (self.delegate && [self.delegate respondsToSelector:@selector(showErrorMessage:withTitle:)]) {
                                                        [self.delegate showErrorMessage:alertText withTitle:alertTitle];
                                                    }
                                                } else {
                                                    // Permission granted, publish the OG story
                                                    [self shareByAPICallEnsureHavePermission];
                                                }
                                                
                                            } else {
                                                // There was an error, handle it
                                                // See https://developers.facebook.com/docs/ios/errors/
                                                [self handleRequestPermissionError:error];
                                            }
                                        }];
}

- (void)handleRequestPermissionError:(NSError *)error {
    NSString *alertText;
    NSString *alertTitle;
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
        // Error requires people using an app to make an out-of-band action to recover
        alertTitle = @"Something went wrong";
        alertText = [FBErrorUtility userMessageForError:error];
        if (self.delegate && [self.delegate respondsToSelector:@selector(showErrorMessage:withTitle:)]) {
            [self.delegate showErrorMessage:alertText withTitle:alertTitle];
        }
        
    } else {
        // We need to handle the error
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            // Ignore it or...
            alertTitle = @"Permission not granted";
            alertText = @"Your post could not be completed because you didn't grant the necessary permissions.";
            if (self.delegate && [self.delegate respondsToSelector:@selector(showErrorMessage:withTitle:)]) {
                [self.delegate showErrorMessage:alertText withTitle:alertTitle];
            }
            
        } else{
            // All other errors that can happen need retries
            // Show the user a generic error message
            alertTitle = @"Something went wrong";
            alertText = @"Please retry";
            if (self.delegate && [self.delegate respondsToSelector:@selector(showErrorMessage:withTitle:)]) {
                [self.delegate showErrorMessage:alertText withTitle:alertTitle];
            }
        }   
    }
}
@end
