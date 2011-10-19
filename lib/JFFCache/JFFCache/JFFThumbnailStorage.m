#import "JFFThumbnailStorage.h"

#import "JFFCacheDB.h"
#import "JFFCaches.h"

#import <UIKit/UIKit.h>

static id storage_instance_ = nil;

@interface JFFThumbnailStorage ()

@property ( nonatomic, strong ) NSMutableDictionary* imagesByUrl;

@end

@implementation JFFThumbnailStorage

@synthesize imagesByUrl = _images_by_url;

-(id)init
{
   self = [ super init ];

   if ( self )
   {
      [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                  selector: @selector( handleMemoryWarning: )
                                                      name: UIApplicationDidReceiveMemoryWarningNotification
                                                    object: [ UIApplication sharedApplication ] ];
   }

   return self;
}

-(void)dealloc
{
   [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];

}

-(NSMutableDictionary*)imagesByUrl
{
   if ( !_images_by_url )
   {
      _images_by_url = [ NSMutableDictionary new ];
   }

   return _images_by_url;
}

+(JFFThumbnailStorage*)sharedStorage
{
   if ( !storage_instance_ )
   {
      storage_instance_ = [ self new ];
   }

   return storage_instance_;
}

-(void)handleMemoryWarning:( NSNotification* )notification_
{
   self.imagesByUrl = nil;
}

+(void)setSharedStorage:( JFFThumbnailStorage* )storage_
{
   storage_instance_ = storage_;
}

-(id< JFFCacheDB >)thumbnailDB
{
   return [ [ JFFCaches sharedCaches ] thumbnailDB ];
}

-(UIImage*)cachedImageForURL:( NSURL* )url_
{
   NSString* url_string_ = [ url_ description ];
   NSData* chached_data_ = [ [ self thumbnailDB ] dataForKey: url_string_ ];

   UIImage* result_image_ = chached_data_ ? [ UIImage imageWithData: chached_data_ ] : nil;
   if ( chached_data_ && !result_image_ )
      NSLog( @"JFFThumbnailStorage: can not create image from cache with url: %@", url_ );
   return result_image_;
}

-(JFFAsyncOperation)createImageBlockWithResultContext:( JFFResultContext* )result_context_
                                               forUrl:( NSURL* )url_
{
   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      UIImage* result_image_ = result_context_.result
         ? [ UIImage imageWithData: result_context_.result ]
         : nil;

      if ( result_context_.result && !result_image_ )
         NSLog( @"JFFThumbnailStorage: can not create image from cache with url: %@", url_ );

      if ( result_image_ )
      {
         [ [ self thumbnailDB ] setData: result_context_.result forKey: [ url_ description ] ];
         done_callback_( result_image_, nil );
      }
      else
      {
         NSError* error_ = result_context_.error
            ? result_context_.error
            : [ JFFError errorWithDescription: @"invalid response" ];
         done_callback_( nil, error_ );
      }

      return JFFEmptyCancelAsyncOperationBlock;
   };
}

-(JFFAsyncOperation)thumbnailLoaderForUrl:( NSURL* )url_
{
   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      if ( !url_ )
      {
         done_callback_( nil, [ JFFError errorWithDescription: @"incorrect url" ] );
         return JFFEmptyCancelAsyncOperationBlock;
      }

      UIImage* cached_image_ = [ self.imagesByUrl objectForKey: url_ ];
      if ( cached_image_ )
      {
         done_callback_( cached_image_, nil );
         return JFFEmptyCancelAsyncOperationBlock;
      }

      cached_image_ = [ self cachedImageForURL: url_ ];
      if ( cached_image_ )
      {
         [ self.imagesByUrl setObject: cached_image_ forKey: url_ ];
         done_callback_( cached_image_, nil );
         return JFFEmptyCancelAsyncOperationBlock;
      }

      JFFAsyncOperation loader_block_ = asyncOperationWithSyncOperation( ^id( NSError** error_ )
      {
         return [ NSData dataWithContentsOfURL: url_ options: NSMappedRead error: error_ ];
      } );
      //loader_block_ = balancedAsyncOperation( loader_block_ );

      JFFResultContext* result_context_ = [ JFFResultContext new ];

      loader_block_ = asyncOperationWithFinishCallbackBlock( loader_block_
                                                            , ^void( id result_, NSError* error_ )
      {
         result_context_.result = result_;
         result_context_.error = error_;
      } );

      JFFAsyncOperation create_image_block_ = [ self createImageBlockWithResultContext: result_context_
                                                                                forUrl: url_ ];

      loader_block_ = sequenceOfAsyncOperations( loader_block_, create_image_block_, nil );

      JFFPropertyPath* property_path_ = [ JFFPropertyPath propertyPathWithName: @"imagesByUrl"
                                                                           key: url_ ];
      JFFAsyncOperation async_loader_ = [ self asyncOperationForPropertyWithPath: property_path_
                                                                  asyncOperation: loader_block_ ];
      return async_loader_( progress_callback_, cancel_callback_, done_callback_ );
   };
}

-(UIImage*)imageForURL:( NSURL* )url_
{
   return [ self.imagesByUrl objectForKey: url_ ];
}

@end
