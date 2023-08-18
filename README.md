# jsonnet-libsonnet

*EXPERIMENTAL*

A Jsonnet library to generate jsonnet code. This library implements functions to create the Jsonnet expressions as represented in the Abstract Syntax. This allows us to generate valid Jsonnet programmatically.

## WHY?

Because I can... and it is fun!

And:

I've implemented [static rendering for CRDsonnet](https://github.com/crdsonnet/crdsonnet#static-rendering) a while back but have never felt very confident in it, the engine has been built through trial-and-error without following the spec. With this library I can now implement a rendering engine that works according to spec, boosting confidence that this will return valid Jsonnet.


## Install

```
jb install github.com/Duologic/jsonnet-libsonnet
```

## Usage

```jsonnet
local j = import 'github.com/Duologic/jsonnet-libsonnet/main.libsonnet';

j.object.members([
  j.member.field.field(
    j.fieldname.id('hello'),
    j.string('world')
  ),
]).toString()
```

Execute it like so:

```
$ jsonnet -S example.jsonnet

{  hello:    'world',}
```

Or execute the resulting jsonnet directly:

```
$ jsonnet -S example.jsonnet | jsonnet -
{
   "hello": "world"
}
```

See [example.jsonnet](./example.jsonnet) for more elaborate examples.
