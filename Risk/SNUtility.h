//
// $Id: SNUtility.h,v 1.1.1.1 1997/12/09 07:18:58 nygard Exp $
// Debug tracing
//

#define DSTART NSLog (@"%@ - %@\n", NSStringFromClass ([self class]), NSStringFromSelector (_cmd))
#define DEND NSLog (@"%@ ~ %@\n", NSStringFromClass ([self class]), NSStringFromSelector (_cmd))

//
// Simple exception handler
//

#define EHAND NSRunAlertPanel ([localException name], @"%@ - %@\n %@", @"OK", nil, nil,\
                               NSStringFromClass ([self class]), NSStringFromSelector (_cmd), [localException reason])


//
// This releases the object if it is non-nil, and then makes
// sure the variable is nil afterward so that we don't have
// references to non-existant objects
//

#if __has_feature(objc_arc)

#define SNRelease(name) name = nil

#else

#define SNRelease(name) \
    if (name != nil) \
    { \
        [name release]; \
        name = nil; \
    }
#endif


//
// Borrowed from Omni
//

#define NSSTRINGIFY(name) @ # name  

#define DEFINE_NSSTRING(name) NSString *const name = NSSTRINGIFY(name)

//
// Other
//

#if 1
#define RCSID(str) \
    __used static inline const char *rcsid (void) \
    { \
        return str " cc:" __DATE__ " " __TIME__; \
    }
#else
#define RCSID(str)
#endif
