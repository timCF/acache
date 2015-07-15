Acache
======

Actor serialization CACHEr. It based on ets tables and erlang actors. 

Usage
-----

Write config where value is init value, and serializer is &function/1 | :json | :none

```
config :acache, 
	actors:	%{
		foo: %{value: [], serializer: :json},
		bar: %{value: %{}, serializer: :none},
		baz: %{value: [], serializer: &Jazz.encode!/1}
	}
```
or start actors dynamic in your app

```
:ok = Acache.init(:bug, %{value: [], serializer: :json})
```
Next, you can cast or call your actors and get serialized or raw values from ets tables. Examples in tests.

Public functions
----------------

```
&Acache.init/2
&Acache.exist?/1

&Acache.cast/2
&Acache.call/2

&Acache.get/1
&Acache.get_raw/1
&Acache.get_full/1

&Acache.force_serialize_cast/1
&Acache.force_serialize_call/1
```

Note
----

I suppose, serializer function is clean, so it call automatically only when raw value was changed. If you wanna enforce serialization , use functions 

```
&Acache.force_serialize_cast/1
&Acache.force_serialize_call/1
```

But it's not true functional way, you see.