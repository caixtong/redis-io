# This file is automatically generated by:
#   scripts/generate_interactive_commands.rb.
#
# Do not edit.
#

module Interactive
  COMMANDS = {
    # connection
    "echo" => [:zip, [nil]],
    "ping" => [],

    # generic
    "del" => [:all],
    "exists" => [:first],
    "expire" => [:first],
    "expireat" => [:first],
    "keys" => [:zip, [nil]],
    "persist" => [:first],
    "pexpire" => [:first],
    "pexpireat" => [:first],
    "pttl" => [:first],
    "rename" => [:all],
    "renamenx" => [:all],
    "sort" => [:custom],
    "ttl" => [:first],
    "type" => [:first],

    # hash
    "hdel" => [:first],
    "hexists" => [:first],
    "hget" => [:first],
    "hgetall" => [:first],
    "hincrby" => [:first],
    "hkeys" => [:first],
    "hlen" => [:first],
    "hmget" => [:first],
    "hmset" => [:first],
    "hset" => [:first],
    "hsetnx" => [:first],
    "hvals" => [:first],

    # list
    "lindex" => [:first],
    "linsert" => [:first],
    "llen" => [:first],
    "lpop" => [:first],
    "lpush" => [:first],
    "lpushx" => [:first],
    "lrange" => [:first],
    "lrem" => [:first],
    "lset" => [:first],
    "ltrim" => [:first],
    "rpop" => [:first],
    "rpoplpush" => [:all],
    "rpush" => [:first],
    "rpushx" => [:first],

    # server
    "info" => [],
    "lastsave" => [],
    "time" => [],

    # set
    "sadd" => [:first],
    "scard" => [:first],
    "sdiff" => [:all],
    "sdiffstore" => [:all],
    "sinter" => [:all],
    "sinterstore" => [:all],
    "sismember" => [:first],
    "smembers" => [:first],
    "smove" => [:zip, [:key, :key, nil]],
    "spop" => [:first],
    "srandmember" => [:first],
    "srem" => [:first],
    "sunion" => [:all],
    "sunionstore" => [:all],

    # sorted_set
    "zadd" => [:first],
    "zcard" => [:first],
    "zcount" => [:first],
    "zincrby" => [:first],
    "zinterstore" => [:custom],
    "zrange" => [:first],
    "zrangebyscore" => [:first],
    "zrank" => [:first],
    "zrem" => [:first],
    "zremrangebyrank" => [:first],
    "zremrangebyscore" => [:first],
    "zrevrange" => [:first],
    "zrevrangebyscore" => [:first],
    "zrevrank" => [:first],
    "zscore" => [:first],
    "zunionstore" => [:custom],

    # string
    "append" => [:first],
    "decr" => [:first],
    "decrby" => [:first],
    "get" => [:first],
    "getbit" => [:first],
    "getrange" => [:first],
    "getset" => [:first],
    "incr" => [:first],
    "incrby" => [:first],
    "mget" => [:all],
    "mset" => [:zip, [:key, nil]],
    "msetnx" => [:zip, [:key, nil]],
    "psetex" => [:first],
    "set" => [:first],
    "setbit" => [:first],
    "setex" => [:first],
    "setnx" => [:first],
    "setrange" => [:first],
    "strlen" => [:first],

  }.freeze
end

