# lua-bit
 
#### **lua-bit** is designed for lua binary operation，and there  is a function like charCodeAt in Javascript supported：
 
  
 
### Example
``` lua
-- 0x0F & 2
bit:_and(0x0F,2)
 
-- 0x0F | 2
bit:_or(0x0F,2)
 
-- 0x0F ^ 2
bit:_xor(0x0F,2)

-- !0x0F 
bit:_not(0x0F)

-- 8<<2( negative number supported if -8<<2)
bit:_lshift(8,2) 【bit:_lshift(-8,2) 】


-- 8>>>2( negative number supported if -8>>>2)
-- >>> take the number as a unsigned value
bit:_frshift(8,2) 【bit:_frshift(-8,2) 】
```
### bit:charCodeAt

>The charCodeAt() method returns the numeric Unicode value of the character at the given index (except for unicode codepoints > 0x10000).

### special Method
javascript  engine using UTF16，characters in `Basic Multilingual Plane` were the same with unicode, but if the characters  were in   `Supplementary Plane`  it should use the formula below，usually we encounter `Supplementary Plane` emoji like <img src="http://dn-noman.qbox.me/FqUnQXIvhJjagidNnIq8UHhuqHlf" width = "20" height = "20" alt="图片名称" align=center />(4  byte UTF8 character)
```lua
-- formula 1
H = Math.floor((c-0x10000) / 0x400)+0xD800 
L = (c - 0x10000) % 0x400 + 0xDC00
```
 
```lua
local str 	=	'你好' 
local allBytes = bit:charCodeAt(str)
-- allBytes is a table contain 6 numbers，while one Chinese characters takes 3 bytes
-- if str contains only 1 emoji，it will return a table contains 2 numbers
```
 ## more details post here http://blog.hellotalk.org/2016/01/16/lua-charCodeAt/
 
## Feedback & Bug Report
- Twitter: [@lilien1010]
- Email: <lilien1010@gmail.com>

----------
Thank you for reading this  , if you got any better idea,  I'm glad to hear from you 
 