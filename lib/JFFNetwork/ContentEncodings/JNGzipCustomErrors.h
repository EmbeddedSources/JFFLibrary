#ifndef JFFNetwork_JNGzipCustomErrors_h
#define JFFNetwork_JNGzipCustomErrors_h

extern NSString* kGzipErrorDomain;

enum JNCustomGzipErrorsEnum
{
     kJNGzipInitFailed    = -100
   , kJNGzipUnexpectedEOF = -101
};

#endif
