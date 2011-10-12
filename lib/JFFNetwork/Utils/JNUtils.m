#import "JNUtils.h"

@implementation JNUtils



+(NSDictionary*)headersDictionadyWithContentType:( NSString* )content_type_
{
   return [ NSDictionary dictionaryWithObject: content_type_
                                       forKey: @"Content-Type" ];
}

+(NSDictionary*)headersDictionadyWithUploadContentType
{
   return [ self headersDictionadyWithContentType: @"application/x-www-form-urlencoded" ];
}

@end
