#!/bin/bash
echo $1|awk -F '' '
BEGIN {_isPal=1}
{
for(i=1;i<=NF/2;i++)
{
        if($i!=$(NF-i+1))
        {
                _isPal=0
                exit
        }
}
}
END { 
        if(_isPal==1)
                print "It is a palindrome"
        else
                print "It is not palindrome"
}
'
