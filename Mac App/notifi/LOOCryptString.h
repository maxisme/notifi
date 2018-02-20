//
//  LOOCryptString.h
//
//  Created by Marcin Swiderski on 6/8/12.
//  Copyright (c) 2012 Marcin Swiderski. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//  
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//
//
// USAGE: To hide the string you just have to surround it with a macro like this:
// 
//     NSString *secret = LOO_CRYPT_STR_N("A7LZ14F88Y", 10);
// 
// Remember to use C-sting, because NSString literals cannot be processed in compile time.
//
// IMPORTANT: Works with -Os (Fastest, Smallest) optimization level.

// __str - C-string.
// __n - Number of characters in string (without trailing \0 character).
#import <Cocoa/Cocoa.h>

#define LOO_CRYPT_STR_N(__str, __n) LOODecrypStrN((const unsigned char []){ LOO_ENCRYPT_STR_TO_CHAR_##__n(__str) }, __n + 1)

// This is not very good encryption macro. You should change it for something stronger probably.
#define LOO_ENCRYPT_STR_CHAR_AT(__str, __i) ((unsigned char)(__str[__i]) ^ 0xFF)

// This must match LOO_ENCRYPT_STR_CHAR_AT.
NSString *LOODecrypStrN(const unsigned char encStr[], size_t n);

#define LOO_ENCRYPT_STR_TO_CHAR_0(__str)  LOO_ENCRYPT_STR_CHAR_AT(__str, 0)

#define LOO_ENCRYPT_STR_TO_CHAR_1(__str)  LOO_ENCRYPT_STR_TO_CHAR_0(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  1)
#define LOO_ENCRYPT_STR_TO_CHAR_2(__str)  LOO_ENCRYPT_STR_TO_CHAR_1(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  2)
#define LOO_ENCRYPT_STR_TO_CHAR_3(__str)  LOO_ENCRYPT_STR_TO_CHAR_2(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  3)
#define LOO_ENCRYPT_STR_TO_CHAR_4(__str)  LOO_ENCRYPT_STR_TO_CHAR_3(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  4)
#define LOO_ENCRYPT_STR_TO_CHAR_5(__str)  LOO_ENCRYPT_STR_TO_CHAR_4(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  5)
#define LOO_ENCRYPT_STR_TO_CHAR_6(__str)  LOO_ENCRYPT_STR_TO_CHAR_5(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  6)
#define LOO_ENCRYPT_STR_TO_CHAR_7(__str)  LOO_ENCRYPT_STR_TO_CHAR_6(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  7)
#define LOO_ENCRYPT_STR_TO_CHAR_8(__str)  LOO_ENCRYPT_STR_TO_CHAR_7(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  8)
#define LOO_ENCRYPT_STR_TO_CHAR_9(__str)  LOO_ENCRYPT_STR_TO_CHAR_8(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  9)
#define LOO_ENCRYPT_STR_TO_CHAR_10(__str)  LOO_ENCRYPT_STR_TO_CHAR_9(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  10)
#define LOO_ENCRYPT_STR_TO_CHAR_11(__str)  LOO_ENCRYPT_STR_TO_CHAR_10(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  11)
#define LOO_ENCRYPT_STR_TO_CHAR_12(__str)  LOO_ENCRYPT_STR_TO_CHAR_11(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  12)
#define LOO_ENCRYPT_STR_TO_CHAR_13(__str)  LOO_ENCRYPT_STR_TO_CHAR_12(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  13)
#define LOO_ENCRYPT_STR_TO_CHAR_14(__str)  LOO_ENCRYPT_STR_TO_CHAR_13(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  14)
#define LOO_ENCRYPT_STR_TO_CHAR_15(__str)  LOO_ENCRYPT_STR_TO_CHAR_14(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  15)
#define LOO_ENCRYPT_STR_TO_CHAR_16(__str)  LOO_ENCRYPT_STR_TO_CHAR_15(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  16)
#define LOO_ENCRYPT_STR_TO_CHAR_17(__str)  LOO_ENCRYPT_STR_TO_CHAR_16(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  17)
#define LOO_ENCRYPT_STR_TO_CHAR_18(__str)  LOO_ENCRYPT_STR_TO_CHAR_17(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  18)
#define LOO_ENCRYPT_STR_TO_CHAR_19(__str)  LOO_ENCRYPT_STR_TO_CHAR_18(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  19)
#define LOO_ENCRYPT_STR_TO_CHAR_20(__str)  LOO_ENCRYPT_STR_TO_CHAR_19(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  20)
#define LOO_ENCRYPT_STR_TO_CHAR_21(__str)  LOO_ENCRYPT_STR_TO_CHAR_20(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  21)
#define LOO_ENCRYPT_STR_TO_CHAR_22(__str)  LOO_ENCRYPT_STR_TO_CHAR_21(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  22)
#define LOO_ENCRYPT_STR_TO_CHAR_23(__str)  LOO_ENCRYPT_STR_TO_CHAR_22(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  23)
#define LOO_ENCRYPT_STR_TO_CHAR_24(__str)  LOO_ENCRYPT_STR_TO_CHAR_23(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  24)
#define LOO_ENCRYPT_STR_TO_CHAR_25(__str)  LOO_ENCRYPT_STR_TO_CHAR_24(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  25)
#define LOO_ENCRYPT_STR_TO_CHAR_26(__str)  LOO_ENCRYPT_STR_TO_CHAR_25(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  26)
#define LOO_ENCRYPT_STR_TO_CHAR_27(__str)  LOO_ENCRYPT_STR_TO_CHAR_26(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  27)
#define LOO_ENCRYPT_STR_TO_CHAR_28(__str)  LOO_ENCRYPT_STR_TO_CHAR_27(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  28)
#define LOO_ENCRYPT_STR_TO_CHAR_29(__str)  LOO_ENCRYPT_STR_TO_CHAR_28(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  29)
#define LOO_ENCRYPT_STR_TO_CHAR_30(__str)  LOO_ENCRYPT_STR_TO_CHAR_29(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  30)
#define LOO_ENCRYPT_STR_TO_CHAR_31(__str)  LOO_ENCRYPT_STR_TO_CHAR_30(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  31)
#define LOO_ENCRYPT_STR_TO_CHAR_32(__str)  LOO_ENCRYPT_STR_TO_CHAR_31(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  32)
#define LOO_ENCRYPT_STR_TO_CHAR_33(__str)  LOO_ENCRYPT_STR_TO_CHAR_32(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  33)
#define LOO_ENCRYPT_STR_TO_CHAR_34(__str)  LOO_ENCRYPT_STR_TO_CHAR_33(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  34)
#define LOO_ENCRYPT_STR_TO_CHAR_35(__str)  LOO_ENCRYPT_STR_TO_CHAR_34(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  35)
#define LOO_ENCRYPT_STR_TO_CHAR_36(__str)  LOO_ENCRYPT_STR_TO_CHAR_35(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  36)
#define LOO_ENCRYPT_STR_TO_CHAR_37(__str)  LOO_ENCRYPT_STR_TO_CHAR_36(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  37)
#define LOO_ENCRYPT_STR_TO_CHAR_38(__str)  LOO_ENCRYPT_STR_TO_CHAR_37(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  38)
#define LOO_ENCRYPT_STR_TO_CHAR_39(__str)  LOO_ENCRYPT_STR_TO_CHAR_38(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  39)
#define LOO_ENCRYPT_STR_TO_CHAR_40(__str)  LOO_ENCRYPT_STR_TO_CHAR_39(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  40)
#define LOO_ENCRYPT_STR_TO_CHAR_41(__str)  LOO_ENCRYPT_STR_TO_CHAR_40(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  41)
#define LOO_ENCRYPT_STR_TO_CHAR_42(__str)  LOO_ENCRYPT_STR_TO_CHAR_41(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  42)
#define LOO_ENCRYPT_STR_TO_CHAR_43(__str)  LOO_ENCRYPT_STR_TO_CHAR_42(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  43)
#define LOO_ENCRYPT_STR_TO_CHAR_44(__str)  LOO_ENCRYPT_STR_TO_CHAR_43(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  44)
#define LOO_ENCRYPT_STR_TO_CHAR_45(__str)  LOO_ENCRYPT_STR_TO_CHAR_44(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  45)
#define LOO_ENCRYPT_STR_TO_CHAR_46(__str)  LOO_ENCRYPT_STR_TO_CHAR_45(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  46)
#define LOO_ENCRYPT_STR_TO_CHAR_47(__str)  LOO_ENCRYPT_STR_TO_CHAR_46(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  47)
#define LOO_ENCRYPT_STR_TO_CHAR_48(__str)  LOO_ENCRYPT_STR_TO_CHAR_47(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  48)
#define LOO_ENCRYPT_STR_TO_CHAR_49(__str)  LOO_ENCRYPT_STR_TO_CHAR_48(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  49)
#define LOO_ENCRYPT_STR_TO_CHAR_50(__str)  LOO_ENCRYPT_STR_TO_CHAR_49(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  50)
#define LOO_ENCRYPT_STR_TO_CHAR_51(__str)  LOO_ENCRYPT_STR_TO_CHAR_50(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  51)
#define LOO_ENCRYPT_STR_TO_CHAR_52(__str)  LOO_ENCRYPT_STR_TO_CHAR_51(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  52)
#define LOO_ENCRYPT_STR_TO_CHAR_53(__str)  LOO_ENCRYPT_STR_TO_CHAR_52(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  53)
#define LOO_ENCRYPT_STR_TO_CHAR_54(__str)  LOO_ENCRYPT_STR_TO_CHAR_53(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  54)
#define LOO_ENCRYPT_STR_TO_CHAR_55(__str)  LOO_ENCRYPT_STR_TO_CHAR_54(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  55)
#define LOO_ENCRYPT_STR_TO_CHAR_56(__str)  LOO_ENCRYPT_STR_TO_CHAR_55(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  56)
#define LOO_ENCRYPT_STR_TO_CHAR_57(__str)  LOO_ENCRYPT_STR_TO_CHAR_56(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  57)
#define LOO_ENCRYPT_STR_TO_CHAR_58(__str)  LOO_ENCRYPT_STR_TO_CHAR_57(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  58)
#define LOO_ENCRYPT_STR_TO_CHAR_59(__str)  LOO_ENCRYPT_STR_TO_CHAR_58(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  59)
#define LOO_ENCRYPT_STR_TO_CHAR_60(__str)  LOO_ENCRYPT_STR_TO_CHAR_59(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  60)
#define LOO_ENCRYPT_STR_TO_CHAR_61(__str)  LOO_ENCRYPT_STR_TO_CHAR_60(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  61)
#define LOO_ENCRYPT_STR_TO_CHAR_62(__str)  LOO_ENCRYPT_STR_TO_CHAR_61(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  62)
#define LOO_ENCRYPT_STR_TO_CHAR_63(__str)  LOO_ENCRYPT_STR_TO_CHAR_62(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  63)
#define LOO_ENCRYPT_STR_TO_CHAR_64(__str)  LOO_ENCRYPT_STR_TO_CHAR_63(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  64)
#define LOO_ENCRYPT_STR_TO_CHAR_65(__str)  LOO_ENCRYPT_STR_TO_CHAR_64(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  65)
#define LOO_ENCRYPT_STR_TO_CHAR_66(__str)  LOO_ENCRYPT_STR_TO_CHAR_65(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  66)
#define LOO_ENCRYPT_STR_TO_CHAR_67(__str)  LOO_ENCRYPT_STR_TO_CHAR_66(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  67)
#define LOO_ENCRYPT_STR_TO_CHAR_68(__str)  LOO_ENCRYPT_STR_TO_CHAR_67(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  68)
#define LOO_ENCRYPT_STR_TO_CHAR_69(__str)  LOO_ENCRYPT_STR_TO_CHAR_68(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  69)
#define LOO_ENCRYPT_STR_TO_CHAR_70(__str)  LOO_ENCRYPT_STR_TO_CHAR_69(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  70)
#define LOO_ENCRYPT_STR_TO_CHAR_71(__str)  LOO_ENCRYPT_STR_TO_CHAR_70(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  71)
#define LOO_ENCRYPT_STR_TO_CHAR_72(__str)  LOO_ENCRYPT_STR_TO_CHAR_71(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  72)
#define LOO_ENCRYPT_STR_TO_CHAR_73(__str)  LOO_ENCRYPT_STR_TO_CHAR_72(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  73)
#define LOO_ENCRYPT_STR_TO_CHAR_74(__str)  LOO_ENCRYPT_STR_TO_CHAR_73(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  74)
#define LOO_ENCRYPT_STR_TO_CHAR_75(__str)  LOO_ENCRYPT_STR_TO_CHAR_74(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  75)
#define LOO_ENCRYPT_STR_TO_CHAR_76(__str)  LOO_ENCRYPT_STR_TO_CHAR_75(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  76)
#define LOO_ENCRYPT_STR_TO_CHAR_77(__str)  LOO_ENCRYPT_STR_TO_CHAR_76(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  77)
#define LOO_ENCRYPT_STR_TO_CHAR_78(__str)  LOO_ENCRYPT_STR_TO_CHAR_77(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  78)
#define LOO_ENCRYPT_STR_TO_CHAR_79(__str)  LOO_ENCRYPT_STR_TO_CHAR_78(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  79)
#define LOO_ENCRYPT_STR_TO_CHAR_80(__str)  LOO_ENCRYPT_STR_TO_CHAR_79(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  80)
#define LOO_ENCRYPT_STR_TO_CHAR_81(__str)  LOO_ENCRYPT_STR_TO_CHAR_80(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  81)
#define LOO_ENCRYPT_STR_TO_CHAR_82(__str)  LOO_ENCRYPT_STR_TO_CHAR_81(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  82)
#define LOO_ENCRYPT_STR_TO_CHAR_83(__str)  LOO_ENCRYPT_STR_TO_CHAR_82(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  83)
#define LOO_ENCRYPT_STR_TO_CHAR_84(__str)  LOO_ENCRYPT_STR_TO_CHAR_83(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  84)
#define LOO_ENCRYPT_STR_TO_CHAR_85(__str)  LOO_ENCRYPT_STR_TO_CHAR_84(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  85)
#define LOO_ENCRYPT_STR_TO_CHAR_86(__str)  LOO_ENCRYPT_STR_TO_CHAR_85(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  86)
#define LOO_ENCRYPT_STR_TO_CHAR_87(__str)  LOO_ENCRYPT_STR_TO_CHAR_86(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  87)
#define LOO_ENCRYPT_STR_TO_CHAR_88(__str)  LOO_ENCRYPT_STR_TO_CHAR_87(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  88)
#define LOO_ENCRYPT_STR_TO_CHAR_89(__str)  LOO_ENCRYPT_STR_TO_CHAR_88(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  89)
#define LOO_ENCRYPT_STR_TO_CHAR_90(__str)  LOO_ENCRYPT_STR_TO_CHAR_89(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  90)
#define LOO_ENCRYPT_STR_TO_CHAR_91(__str)  LOO_ENCRYPT_STR_TO_CHAR_90(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  91)
#define LOO_ENCRYPT_STR_TO_CHAR_92(__str)  LOO_ENCRYPT_STR_TO_CHAR_91(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  92)
#define LOO_ENCRYPT_STR_TO_CHAR_93(__str)  LOO_ENCRYPT_STR_TO_CHAR_92(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  93)
#define LOO_ENCRYPT_STR_TO_CHAR_94(__str)  LOO_ENCRYPT_STR_TO_CHAR_93(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  94)
#define LOO_ENCRYPT_STR_TO_CHAR_95(__str)  LOO_ENCRYPT_STR_TO_CHAR_94(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  95)
#define LOO_ENCRYPT_STR_TO_CHAR_96(__str)  LOO_ENCRYPT_STR_TO_CHAR_95(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  96)
#define LOO_ENCRYPT_STR_TO_CHAR_97(__str)  LOO_ENCRYPT_STR_TO_CHAR_96(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  97)
#define LOO_ENCRYPT_STR_TO_CHAR_98(__str)  LOO_ENCRYPT_STR_TO_CHAR_97(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  98)
#define LOO_ENCRYPT_STR_TO_CHAR_99(__str)  LOO_ENCRYPT_STR_TO_CHAR_98(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  99)
#define LOO_ENCRYPT_STR_TO_CHAR_100(__str)  LOO_ENCRYPT_STR_TO_CHAR_99(__str),  LOO_ENCRYPT_STR_CHAR_AT(__str,  100)

@interface LOOCryptString : NSObject
+(NSString*)serverKey;
@end
