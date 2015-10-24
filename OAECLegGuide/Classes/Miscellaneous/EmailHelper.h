//
//  EmailHelper.h
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface EmailHelper : NSObject <MFMailComposeViewControllerDelegate>

-(void) emailNotes:(NSString *)notes forName:(NSString *)name fromViewController:(UIViewController *)viewController;


@end
