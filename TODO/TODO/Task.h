//
//  Task.h
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityHigh,
    TaskPriorityMedium,
    TaskPriorityLow
};

typedef NS_ENUM(NSInteger, TaskStatus) {
    TaskStatusToDo,
    TaskStatusInProgress,
    TaskStatusDone
};

@interface Task : NSObject <NSCoding>

@property (nonatomic, strong) NSString *taskID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *taskDescription;
@property (nonatomic, assign) TaskPriority priority;
@property (nonatomic, assign) TaskStatus status;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSDate *reminderDate;
@property (nonatomic, strong) NSString *attachedFilePath;
@property (nonatomic, strong) NSString *attachedFileName;

// Reconstructs the full path from filename (survives app restarts)
- (NSString *)resolvedFilePath;

@end
