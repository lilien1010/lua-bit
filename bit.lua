local utf8 = {}
local bit={data32={}}  
for i=1,32 do  
    bit.data32[i]=2^(32-i)  
end 
local toby = string.byte
function utf8.charbytes(s,i) 
   i = i or 1
   local c = string.byte(s,i)  
   if c > 0 and c <= 127 then 
      return 1
   elseif c >= 194 and c <= 223 then  
      return 2
   elseif c >= 224 and c <= 239 then  
      return 3
   elseif c >= 240 and c <= 244 then  
      return 4
   end
   return 1
end  
function bit:d2b(arg)  
    local   tr,c={},arg<0 
    if c then arg=0-arg end
    for i=1,32 do  
        if arg >= self.data32[i] then  
          tr[i]=1  
          arg=arg-self.data32[i]  
        else  
          tr[i]=0  
        end  
    end
    if c then
      tr = self:_bnot(tr); 
      tr = self:b2d(tr)+ 1
      tr = self:d2b(tr)
    end 
    return   tr  
end

function bit:b2d(arg,neg)  
    local nr=0
    if arg[1]==1 and neg==true then
        arg = self:_bnot(arg); 
        nr = self:b2d(arg)  + 1
        nr = 0 - nr;
    else 
      for i=1,32 do  
          if arg[i] ==1  then  
            nr=nr+2^(32-i)  
          end  
      end   
    end 
    return  nr  
end  
function bit:_and(a,b)  
    local   op1=self:d2b(a)  
    local   op2=self:d2b(b)  
    local   r={}  
      
    for i=1,32 do  
        if op1[i]==1 and op2[i]==1  then  
            r[i]=1  
        else  
            r[i]=0  
        end  
    end  
    return  self:b2d(r,true)  
end

function bit:_or(a,b)  
    local op1=self:d2b(a)  
    local op2=self:d2b(b)  
    local r={}
    for i=1,32 do  
        if  op1[i]==1 or   op2[i]==1   then  
            r[i]=1  
        else  
            r[i]=0  
        end  
    end  
    return  self:b2d(r,true)  
end

function bit:_xor(a,b)  
    local   op1=self:d2b(a)  
    local   op2=self:d2b(b)  
    local   r={}   
    for i=1,32 do  
        if op1[i]==op2[i] then  
            r[i]=0  
        else  
            r[i]=1  
        end  
    end  
    return  self:b2d(r,true)  
end

local switch = {
	[1]		=	function (s,pos)
		local c1  =toby(s, pos);
		return c1
	end,
	[2]		=	function (s,pos)
	
		local c1  =toby(s, pos);
		local c2  =toby(s, pos+1);
		
		local int1 	=	bit:_and(0x1F,c1)
		local int2 	=	bit:_and(0x3F,c2)  
		return 	bit:_or(bit:_lshift(int1,6),int2)
	end,
	[3]		=	function (s,pos)

		local c1  =toby(s, pos);
		local c2  =toby(s, pos+1);
		local c3  =toby(s, pos+2);
		
		local int1 	=	bit:_and(0x0F,c1)
		local int2 	=	bit:_and(0x3F,c2)  
		local int3 	=	bit:_and(0x3F,c3)  
		
		local o2 = bit:_or(bit:_lshift(int1,12), bit:_lshift(int2,6))
		local dt =	bit:_or(o2,int3);
		
		return dt 
	end,
	[4]		=	function (s,pos)
		local c1  = toby(s, pos);
		local c2  = toby(s, pos+1);
		local c3  = toby(s, pos+2);
		local c4  = toby(s, pos+3);
		
		local int1 	=	bit:_and(0x0F,c1)
		local int2 	=	bit:_and(0x3F,c2)  
		local int3 	=	bit:_and(0x3F,c3)  
		local int4 	=	bit:_and(0x3F,c4)  

		local o2 = bit:_or(bit:_lshift(int1,18), bit:_lshift(int2,12))
		local o3 = bit:_or(o2,bit:_lshift(int3,6))
		local o4 = bit:_or(o3,int4) 
		return o4  
	end,
}

function bit:_bnot(op1)
   local   r={}  
    for i=1,32 do  
        if op1[i]==1 then  
            r[i]=0  
        else  
            r[i]=1  
        end  
    end
    return r
end

function bit:_not(a)  
    local op1=self:d2b(a)  
    local r=self:_bnot(op1)
    return self:b2d(r,true)  
end
  
function bit:charCodeAt(s)
	local pos,int,H,L=1,0,0,0
	local slen = string.len(s)
	local allByte 	= {} 
	while pos <= slen do
	 local tLen 	=	utf8.charbytes(s,pos) 
	 if tLen >=1 and tLen<=4 then
		if tLen == 4 then  
			int = switch[4](s,pos )  
			--兼容 js的 unicode 16 编码 ,unicode 到 UTF16的转换
			H = math.floor((int-0x10000) / 0x400)+0xD800
			L = (int - 0x10000) % 0x400 + 0xDC00  
			table.insert(allByte,H)	 	
			table.insert(allByte,L)	 	
		else
			int = switch[tLen](s,pos )
			table.insert(allByte,int)			
		end 
	 end 
	  pos = pos + tLen
	end
	return allByte;
end
 
function bit:_rshift(a,n)  
        local r=0
        if a < 0 then
          r=0-self:_frshift(0-a,n); 
        elseif a>= 0 then 
          r=self:_frshift(a,n);
        end 
        return r
end
function bit:_frshift(a,n) 
    local op1=self:d2b(a)  
    local r=self:d2b(0)  
    local left = 32 -n 
    if n < 32 and n > 0 then  
      for i=left,1,-1 do  
        r[i+n]=op1[i]  
      end   
    end
    return self:b2d(r)        
end
function bit:_lshift(a,n)
    local   op1=self:d2b(a)  
    local   r=self:d2b(0)    
    if n < 32 and n > 0 then   
      for i=n,31 do
        r[i-n+1]=op1[i+1]  
      end     
    end      
    return  self:b2d(r,true)  
end

return bit