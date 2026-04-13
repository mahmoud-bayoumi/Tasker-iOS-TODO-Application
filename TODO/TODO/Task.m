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
    // ONLY save filename — full path changes between launches
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
        _attachedFileName = [coder decodeObjectForKey:@"attachedFileName"];
        
        // Reconstruct full path from filename
        if (_attachedFileName) {
            _attachedFilePath = [self filePathForName:_attachedFileName];
        }
    }
    return self;
}

#pragma mark - File Path Helpers

- (NSString *)filePathForName:(NSString *)fileName {
    if (!fileName) return nil;
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [docsDir stringByAppendingPathComponent:fileName];
}

- (NSString *)resolvedFilePath {
    if (!self.attachedFileName) return nil;
    
    // Always rebuild from filename — sandbox path may have changed
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [docsDir stringByAppendingPathComponent:self.attachedFileName];
    
    // Keep stored path in sync
    self.attachedFilePath = path;
    
    return path;
}

@end
