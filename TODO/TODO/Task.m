//
//  Task.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import "Task.h"

@implementation Task

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskID = [[NSUUID UUID] UUIDString];
        _createdDate = [NSDate date];
        _status = TaskStatusToDo;
        _priority = TaskPriorityMedium;
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_taskID forKey:@"taskID"];
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_taskDescription forKey:@"taskDescription"];
    [coder encodeInteger:_priority forKey:@"priority"];
    [coder encodeInteger:_status forKey:@"status"];
    [coder encodeObject:_createdDate forKey:@"createdDate"];
    [coder encodeObject:_reminderDate forKey:@"reminderDate"];
    [coder encodeObject:_attachedFilePath forKey:@"attachedFilePath"];
    [coder encodeObject:_attachedFileName forKey:@"attachedFileName"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _taskID = [coder decodeObjectForKey:@"taskID"];
        _name = [coder decodeObjectForKey:@"name"];
        _taskDescription = [coder decodeObjectForKey:@"taskDescription"];
        _priority = [coder decodeIntegerForKey:@"priority"];
        _status = [coder decodeIntegerForKey:@"status"];
        _createdDate = [coder decodeObjectForKey:@"createdDate"];
        _reminderDate = [coder decodeObjectForKey:@"reminderDate"];
        _attachedFilePath = [coder decodeObjectForKey:@"attachedFilePath"];
        _attachedFileName = [coder decodeObjectForKey:@"attachedFileName"];
    }
    return self;
}

@end
