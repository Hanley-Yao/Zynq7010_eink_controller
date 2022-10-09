/*-------------------------------------------*/
/* Integer type definitions for FatFs module */
/*-------------------------------------------*/

// This file is ugly because it defines types like BYTE which have other defines
// in the Arduino / MPIDE types. So only define these for the FATFS code, and then undefine them
// also make sure to define them as types known by the Arduino / MPIDE types (inttypes)

#if !defined(_FF_DEFINED) && defined(_FF_DEFINE_INTEGER)
#define _FF_DEFINED
#include <inttypes.h>

/* This type MUST be 8 bit */
#define BYTE    uint8_t

/* These types MUST be 16 bit */
#define SHORT uint16_t
#define WORD uint16_t
#define WCHAR uint16_t

/* These types MUST be 16 bit or 32 bit */
#define INT int32_t
#define UINT uint32_t

/* These types MUST be 32 bit */
#define LONG int32_t
#define DWORD uint32_t

#elif defined(_FF_DEFINED) && defined(_FF_UNDEFINE_INTEGER)

/* This type MUST be 8 bit */
#undef BYTE

/* These types MUST be 16 bit */
#undef SHORT
#undef WORD
#undef WCHAR

/* These types MUST be 16 bit or 32 bit */
#undef INT
#undef UINT

/* These types MUST be 32 bit */
#undef LONG
#undef DWORD
#undef _FF_DEFINED

#elif !defined(_FF_DEFINED) && !defined(_FF_UNDEFINE_INTEGER)
    #ifndef _FF_INTEGER
    #define _FF_INTEGER

    /* This type MUST be 8 bit */
    typedef unsigned char	BYTE;

    /* These types MUST be 16 bit */
    typedef short			SHORT;
    typedef unsigned short	WORD;
    typedef unsigned short	WCHAR;

    /* These types MUST be 16 bit or 32 bit */
    typedef int				INT;
    typedef unsigned int	UINT;

    /* These types MUST be 32 bit */
    typedef long			LONG;
    typedef unsigned long	DWORD;
    #endif
#endif 

