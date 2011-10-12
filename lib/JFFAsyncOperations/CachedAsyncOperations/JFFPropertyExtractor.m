#import "JFFPropertyExtractor.h"

#import "JFFPropertyPath.h"
#import "JFFObjectRelatedPropertyData.h"

#import "NSObject+PropertyExtractor.h"

@interface JFFPropertyExtractor ()

@property ( nonatomic, retain ) JFFObjectRelatedPropertyData* objectPropertyData;

@property ( nonatomic, assign, readonly ) SEL propertyGetSelector;
@property ( nonatomic, assign, readonly ) SEL propertySetSelector;

@end

@implementation JFFPropertyExtractor

@synthesize propertyPath = _property_path;
@synthesize object = _object;

-(void)dealloc
{
   [ _property_path release ];
   [ _object release ];

   [ super dealloc ];
}

-(void)clearData
{
   self.objectPropertyData = nil;
   self.object = nil;
   //self.propertyPath = nil;
}

-(SEL)propertyGetSelector
{
   if ( !_property_get_selector )
   {
      _property_get_selector = NSSelectorFromString( self.propertyPath.name );
   }
   return _property_get_selector;
}

-(SEL)propertySetSelector
{
   if ( !_property_set_selector )
   {
      _property_set_selector = NSSelectorFromString( [ NSString propertySetNameFromPropertyName: self.propertyPath.name ] );
   }
   return _property_set_selector;
}

-(id)property
{
   id result_ = [ self.object performSelector: self.propertyGetSelector ];
   return self.propertyPath.key ? [ result_ objectForKey: self.propertyPath.key ] : result_;
}

-(void)setProperty:( id )property_
{
   if ( !self.propertyPath.key )
   {
      [ self.object performSelector: self.propertySetSelector withObject: property_ ];
      return;
   }

   NSMutableDictionary* dict_ = [ self.object performSelector: self.propertyGetSelector ];

   if ( !dict_ )
   {
      dict_ = [ NSMutableDictionary dictionary ];
      [ self.object performSelector: self.propertySetSelector withObject: dict_ ];
   }

   if ( property_ )
   {
      [ dict_ setObject: property_ forKey: self.propertyPath.key ];
      return;
   }

   [ dict_ removeObjectForKey: self.propertyPath.key ];
}

////////////////////////OBJECT RELATED DATA///////////////////////

-(JFFObjectRelatedPropertyData*)objectPropertyData
{
   JFFObjectRelatedPropertyData* data_ = [ self.object propertyDataForPropertPath: self.propertyPath ];
   if ( !data_ )
   {
      data_ = [ [ JFFObjectRelatedPropertyData new ] autorelease ];
      [ self.object setPropertyData: data_ forPropertPath: self.propertyPath ];
   }
   return data_;
}

-(void)setObjectPropertyData:( JFFObjectRelatedPropertyData* )object_property_data_
{
   [ self.object setPropertyData: object_property_data_ forPropertPath: self.propertyPath ];
}

-(NSMutableArray*)delegates
{
   return self.objectPropertyData.delegates;
}

-(void)setDelegates:( NSMutableArray* )delegates_
{
   self.objectPropertyData.delegates = delegates_;
}

-(JFFAsyncOperation)asyncLoader
{
   return self.objectPropertyData.asyncLoader;
}

-(void)setAsyncLoader:( JFFAsyncOperation )async_loader_
{
   self.objectPropertyData.asyncLoader = async_loader_;
}

-(JFFDidFinishAsyncOperationHandler)didFinishBlock
{
   return self.objectPropertyData.didFinishBlock;
}

-(void)setDidFinishBlock:( JFFDidFinishAsyncOperationHandler )did_finish_block_
{
   self.objectPropertyData.didFinishBlock = did_finish_block_;
}

-(JFFCancelAsyncOperation)cancelBlock
{
   return self.objectPropertyData.cancelBlock;
}

-(void)setCancelBlock:( JFFCancelAsyncOperation )cancel_block_
{
   self.objectPropertyData.cancelBlock = cancel_block_;
}

@end
