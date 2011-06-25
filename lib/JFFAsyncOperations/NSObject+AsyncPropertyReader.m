#import "NSObject+AsyncPropertyReader.h"

#import "JFFPropertyPath.h"
#import "JFFPropertyExtractor.h"
#import "JFFObjectRelatedPropertyData.h"
#import "JFFCallbacksBlocks.h"

#import "NSObject+PropertyExtractor.h"

#import <JFFUtils/NSThread+AssertMainThread.h>
#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>

#include <objc/runtime.h>
#include <assert.h>

static void clearDataForPropertyExtractor( JFFPropertyExtractor* property_extractor_ )
{
   [ property_extractor_.delegates each: ^( id obj_ )
   {
      JFFCallbacksBlocks* callback_ = obj_;
      callback_.didLoadDataBlock = nil;
      callback_.onProgressBlock = nil;
   } ];
   property_extractor_.delegates = nil;
   property_extractor_.cancelBlock = nil;
   property_extractor_.didFinishBlock = nil;
   property_extractor_.asyncLoader = nil;

   [ property_extractor_ clearData ];
}

static JFFCancelAsyncOperation cancelBlock( JFFPropertyExtractor* property_extractor_, JFFCallbacksBlocks* callbacks_ )
{
   return [ [ ^( BOOL cancel_operation_ )
   {
      [ property_extractor_.delegates removeObject: callbacks_ ];
      callbacks_.didLoadDataBlock = nil;
      callbacks_.onProgressBlock = nil;

      JFFCancelAsyncOperation cancel_ = [ property_extractor_.cancelBlock copy ];

      if ( [ property_extractor_.delegates count ] == 0
          || cancel_operation_ )
      {
         clearDataForPropertyExtractor( property_extractor_ );
      }

      if ( cancel_ )
      {
         cancel_( cancel_operation_ );
         [ cancel_ release ];
      }
   } copy ] autorelease ];
}

static JFFDidFinishAsyncOperationHandler doneCallbackBlock( JFFPropertyExtractor* property_extractor_ )
{
   return [ [ ^( id result_, NSError* error_ )
   {
      [ NSThread assertMainThread ];

      if ( !result_ && !error_ )
      {
         NSLog( @"Assert propertyPath object: %@ propertyPath: %@", property_extractor_.object, property_extractor_.propertyPath );
         assert( 0 );//@"should be result or error"
      }

      NSArray* copy_delegates_ = [ property_extractor_.delegates map: ^( id obj_ )
      {
         JFFCallbacksBlocks* callback_ = obj_;
         return (id)[ JFFCallbacksBlocks callbacksBlocksWithOnProgressBlock: callback_.onProgressBlock
                                                           didLoadDataBlock: callback_.didLoadDataBlock ];
      } ];

      JFFDidFinishAsyncOperationHandler finish_block_ = [ [ property_extractor_.didFinishBlock copy ] autorelease ];

      property_extractor_.property = result_;

      if ( finish_block_ )
      {
         finish_block_( result_, error_ );
         result_ = property_extractor_.property;
      }

      clearDataForPropertyExtractor( property_extractor_ );

      [ copy_delegates_ each: ^( id obj_ )
      {
         JFFCallbacksBlocks* callback_ = obj_;
         if ( callback_.didLoadDataBlock )
            callback_.didLoadDataBlock( result_, result_ ? nil : error_ );
      } ];

      [ copy_delegates_ each: ^( id obj_ )
      {
         JFFCallbacksBlocks* callback_ = obj_;
         callback_.didLoadDataBlock = nil;
         callback_.onProgressBlock = nil;
      } ];
   } copy ] autorelease ];
}

@interface NSObject (PrivateAsyncPropertyReader)

-(BOOL)hasAsyncPropertyDelegates;

@end

@interface NSDictionary (AsyncPropertyReader)
@end

@implementation NSDictionary (AsyncPropertyReader)

-(BOOL)hasAsyncPropertyDelegates
{
   if ( [ self count ] == 0 )
      return NO;

   for ( NSObject* value_ in [ self allValues ] )
   {
      if ( [ value_ hasAsyncPropertyDelegates ] )
         return YES;
   }

   return NO;
}

@end

@interface JFFObjectRelatedPropertyData (AsyncPropertyReader)
@end

@implementation JFFObjectRelatedPropertyData (AsyncPropertyReader)

-(BOOL)hasAsyncPropertyDelegates
{
   return [ self.delegates count ] > 0;
}

@end

@implementation NSObject (AsyncPropertyReader)

-(BOOL)hasAsyncPropertyDelegates
{
   return NO;
}

-(BOOL)isLoadingPropertyForPropertyName:( NSString* )name_
{
   return [ [ self.propertyDataByPropertyName objectForKey: name_ ] hasAsyncPropertyDelegates ];
}

-(JFFAsyncOperation)privateAsyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                              asyncOperation:( JFFAsyncOperation )async_operation_
                                      didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_
{
   NSAssert( async_operation_, @"async_operation_ should be set" );

   async_operation_ = [ [ async_operation_ copy ] autorelease ];
   did_finish_operation_ = [ [ did_finish_operation_ copy ] autorelease ];

   __block id self_ = self;

   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      [ NSThread assertMainThread ];

      JFFPropertyExtractor* property_extractor_ = [ JFFPropertyExtractor propertyForObject: self_
                                                                              propertyPath: property_path_ ];

      id result_ = property_extractor_.property;
      if ( result_ )
      {
         done_callback_( result_, nil );
         return (JFFCancelAsyncOperation)[ [ ^( BOOL cancel_ ){ /*do nothing*/ } copy ] autorelease ];
      }

      property_extractor_.asyncLoader = async_operation_;
      property_extractor_.didFinishBlock = did_finish_operation_;

      JFFCallbacksBlocks* callbacks_ = [ JFFCallbacksBlocks callbacksBlocksWithOnProgressBlock: progress_callback_
                                                                              didLoadDataBlock: done_callback_ ];

      NSMutableArray* delegates_ = property_extractor_.delegates;
      if ( nil == delegates_ )
      {
         property_extractor_.delegates = [ NSMutableArray arrayWithObject: callbacks_ ];
         delegates_ = property_extractor_.delegates;
      }

      JFFCancelAsyncOperation main_cancel_ = cancelBlock( property_extractor_, callbacks_ );

      if ( nil == property_extractor_.cancelBlock )
      {
         JFFAsyncOperationProgressHandler progress_callback_ = ^( id progress_info_ )
         {
            [ delegates_ each: ^( id obj_ )
             {
                JFFCallbacksBlocks* obj_callback_ = obj_;
                if ( obj_callback_.onProgressBlock )
                   obj_callback_.onProgressBlock( progress_info_ );
             } ];
         };

         JFFDidFinishAsyncOperationHandler done_callback_ = doneCallbackBlock( property_extractor_ );

         cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
         cancel_callback_ = [ [ ^( BOOL canceled_ )
         {
            clearDataForPropertyExtractor( property_extractor_ );

            if ( cancel_callback_ )
               cancel_callback_( canceled_ );
         } copy ] autorelease ];

         property_extractor_.cancelBlock = property_extractor_.asyncLoader( progress_callback_
                                                                           , cancel_callback_
                                                                           , done_callback_ );

         if ( nil == property_extractor_.cancelBlock )
         {
            return (JFFCancelAsyncOperation)[ [ ^( BOOL cancel_ ){ /*do nothing*/ } copy ] autorelease ];
         }

         return main_cancel_;
      }
      [ delegates_ addObject: callbacks_ ];

      return main_cancel_;
   } copy ] autorelease ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )property_name_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_
{
   NSAssert( property_name_, @"propertyName argument should not be nil" );
   return [ self privateAsyncOperationForPropertyWithPath: [ JFFPropertyPath propertyPathWithName: property_name_ key: nil ]
                                           asyncOperation: async_operation_
                                   didFinishLoadDataBlock: did_finish_operation_ ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )property_name_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
{
   NSAssert( property_name_, @"propertyName argument should not be nil" );
   return [ self privateAsyncOperationForPropertyWithPath: [ JFFPropertyPath propertyPathWithName: property_name_ key: nil ]
                                           asyncOperation: async_operation_
                                   didFinishLoadDataBlock: nil ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
{
   NSAssert( property_path_.name && property_path_.key, @"propertyName argument should not be nil" );
   return [ self privateAsyncOperationForPropertyWithPath: property_path_
                                           asyncOperation: async_operation_
                                   didFinishLoadDataBlock: nil ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_
{
   NSAssert( property_path_.name && property_path_.key, @"propertyName argument should not be nil" );
   return [ self privateAsyncOperationForPropertyWithPath: property_path_
                                           asyncOperation: async_operation_
                                   didFinishLoadDataBlock: did_finish_operation_ ];
}

@end
