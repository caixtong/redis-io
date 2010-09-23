

_Time complexity: O(N) (with N being the number of fields)_

Set the respective fields to the respective values. HMSET replaces old values with new values.

If _key_ does not exist, a new key holding a hash is created.

## Return value

[Status code reply][1] Always +OK because HMSET can't fail



[1]: /p/redis/wiki/ReplyTypes
