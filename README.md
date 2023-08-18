# jsonnet-libsonnet

*EXPERIMENTAL*

A Jsonnet library to generate jsonnet code. This library implements functions to create the Jsonnet expressions as represented in the Abstract Syntax. This allows us to generate valid Jsonnet programmatically.

## WHY?

Because I can... and it is fun!

And:

I've implemented [static rendering for CRDsonnet](https://github.com/crdsonnet/crdsonnet#static-rendering) a while back but have never felt very confident in it, the engine has been built through trial-and-error without following the spec. With this library I can now implement a rendering engine that works according to spec, boosting confidence that this will return valid Jsonnet.

## Usage

See [example.libsonnet](./example.libsonnet) on how to use it.

Execute it like so:

```
jsonnet -S example.libsonnet
```

Or to directly execute the resulting jsonnet:

```
jsonnet -S example.libsonnet | jsonnet -
```
