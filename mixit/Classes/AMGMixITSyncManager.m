//
//  AMGMixITSyncManager.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "AMGMixITSyncManager.h"

#import "AMGMixITClient.h"

#import "AMGTalk.h"
#import "AMGTalk+MixITResource.h"

#import "AMGMember.h"
#import "AMGMember+MixITResource.h"

@interface AMGMixITSyncManager ()

@property (nonatomic, assign, getter = isSyncing) BOOL syncing;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) AMGMixITClient *client;

@end


@implementation AMGMixITSyncManager

+ (instancetype)MixITSyncManagerWithContext:(NSManagedObjectContext *)context {
    AMGMixITSyncManager *manager = [AMGMixITSyncManager new];

    manager.context = context;
    manager.syncing = NO;
    manager.client  = [AMGMixITClient MixITClient];

    return manager;
}

- (BOOL)startSyncForYear:(nullable NSNumber *)year {
    if (self.isSyncing) {
        return NO;
    }

    self.syncing = YES;

    [self.delegate syncManagerDidStartSync:self];

    [AMGTalk
     fetchTalksWithClient:self.client
     forYear:year
     block:^(NSArray *posts, NSError *error) {
         if (error) {
             self.syncing = NO;
             [self.delegate syncManager:self
                   didFailSyncWithError:error];
             return;
         }

         [AMGTalk mergeResponseObjects:posts
                           intoContext:self.context];

         [self syncSpeakersForYear:year];
     }];
    return YES;
}

- (void)syncSpeakersForYear:(nullable NSNumber *)year {
    [AMGMember
     fetchSpeakersWithClient:self.client
     forYear:year
     block:^(NSArray *speakers, NSError *error) {
         if (error) {
             self.syncing = NO;
             [self.delegate syncManager:self
                   didFailSyncWithError:error];
             return;
         }

         [AMGMember mergeResponseObjects:speakers
                             intoContext:self.context];

         [self.context save:nil];

         self.syncing = NO;
         [self.delegate syncManagerDidFinishSync:self];
     }];
}

@end
