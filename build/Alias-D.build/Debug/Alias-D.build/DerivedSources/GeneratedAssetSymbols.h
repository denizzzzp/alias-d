#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "aliase-d" asset catalog image resource.
static NSString * const ACImageNameAliaseD AC_SWIFT_PRIVATE = @"aliase-d";

#undef AC_SWIFT_PRIVATE
