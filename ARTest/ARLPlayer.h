//
//  ARLPlayer.h
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARLPlayer : NSObject
@property(nonatomic, strong) NSNumber* distanceFromMe; // in miles
@property(nonatomic, strong) NSNumber* angle; // in radians

- (id) initWithDefinition:(NSDictionary*)definition;

@end
