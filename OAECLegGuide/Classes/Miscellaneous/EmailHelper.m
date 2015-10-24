//
//  EmailHelper.m
//


#import "EmailHelper.h"
#import "ModalAlert.h"

@interface EmailHelper()

@property (nonatomic, retain) UIViewController *viewController;

@end


@implementation EmailHelper


-(void) emailNotes:(NSString *)notes forName:(NSString *)name fromViewController:(UIViewController *)viewController {
    
    if (![MFMailComposeViewController canSendMail]) {
        [ModalAlert okWithTitle:@"Got email?" message:@"Sorry, but it looks like you've haven't configured this device to send email.  Setup email and try again later."];
        return;
    }
    
    self.viewController=viewController;
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:[NSString stringWithFormat:@"%@ Notes",name]];
    [controller setMessageBody:notes isHTML:NO];
    //if (controller) [viewController presentModalViewController:controller animated:YES];
    if (controller) [viewController presentViewController:controller animated:YES completion:nil];
    [controller release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    //[self.viewController dismissModalViewControllerAnimated:YES];
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}


-(void) dealloc {
    [_viewController release];
    [super dealloc];
}

@end
