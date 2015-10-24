//
//  NSDictionary+Committee.m
//  LegGuide
//
//  Created by Matt Galloway on 1/26/14.
//  Copyright (c) 2014 Architactile LLC. All rights reserved.
//

#import "NSDictionary+Committee.h"

@implementation NSDictionary (Committee)

-(NSString *) committeeChamber{
    return [self objectForKey:@"Chamber"];
}
-(NSString *) committeeName{
    return [self objectForKey:@"Committee"];
}
-(NSString *) committeeDOW{
    return [self objectForKey:@"Day of Week"];
}
-(NSString *) committeeTime{
    return [self objectForKey:@"Time"];
}
-(NSString *) committeeRoom{
    return [self objectForKey:@"Room"];
}
-(NSString *) committeeWebsite{
    return [self objectForKey:@"Member List Website"];
}

@end


