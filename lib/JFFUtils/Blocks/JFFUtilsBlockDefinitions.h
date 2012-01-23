#ifndef JFF_UTILS_BLOCK_DEFINITIONS
#define JFF_UTILS_BLOCK_DEFINITIONS

#include <objc/objc.h>

typedef void (^JFFSimpleBlock)( void );
typedef BOOL (^PredicateBlock)( id object_ );//JTODO rename to JPredicateBlock

#endif //JFF_UTILS_BLOCK_DEFINITIONS
