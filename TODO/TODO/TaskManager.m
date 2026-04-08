//
//  TaskManager.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import "TaskManager.h"

@implementation TaskManager

+ (instancetype)sharedManager {
    static TaskManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[TaskManager alloc] init];
        [shared loadTasks];
    });
    return shared;
}

- (void)saveTasks {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.tasks
                                         requiringSecureCoding:NO
                                                        error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"savedTasks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadTasks {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTasks"];
    if (data) {
        self.tasks = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    } else {
        self.tasks = [NSMutableArray new];
    }
}

- (void)addTask:(Task *)task {
    [self.tasks addObject:task];
    [self saveTasks];
}

- (void)removeTask:(Task *)task {
    [self.tasks removeObject:task];
    [self saveTasks];
}

- (void)updateTask:(Task *)task {
    [self saveTasks];
}

@end
