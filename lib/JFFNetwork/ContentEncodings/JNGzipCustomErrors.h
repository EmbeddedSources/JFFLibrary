#ifndef JFFNetwork_JNGzipCustomErrors_h
#define JFFNetwork_JNGzipCustomErrors_h

extern NSString* GZIP_ERROR_DOMAIN;

enum JNCustomGzipErrorsEnum
{
     JNGzipInitFailed    = -100
   , JNGzipUnexpectedEOF = -101
};

#endif
