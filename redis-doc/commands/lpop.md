

_Time complexity: O(1)_

Atomically return and remove the first (LPOP) or last (RPOP) elemen
of the list. For example if the list contains the elements a,b,c LPOP
will return a and the list will become b,c.

If the _key_ does not exist or the list is already empty the special
value 'nil' is returned.

## Return value

[Bulk reply][1]



[1]: /p/redis/wiki/ReplyTypes
