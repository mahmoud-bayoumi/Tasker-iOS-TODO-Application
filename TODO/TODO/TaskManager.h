//
//  TaskManager.h
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface TaskManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) NSMutableArray<Task *> *tasks;

- (void)saveTasks;
- (void)loadTasks;
- (void)addTask:(Task *)task;
- (void)removeTask:(Task *)task;
- (void)updateTask:(Task *)task;

@end
