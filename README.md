# ErlPort

*A Julia-Erlang module for using the External Term Format from Julia*

Though this module can be used stand-alone, it was originally designed to be
used with the [ErlPort](http://erlport.org/) project, allowing Julia code to
be run from [Erlang](http://www.erlang.org/) and [LFE](http://lfe.io/),
sending its results back as Erlang terms.

## Prerequisites

*   ErlPort.jl works with Julia 1.0.

## Installation

The following example shows installing ErlPort on a clean Julia installation and
is useful for development purposes. For using this package in production, it is
better to include it in your Julia registry.

*   Clone this git repository.

*   Open a Julia shell:

    ```
    $ julia
                   _
       _       _ _(_)_     |  Documentation: https://docs.julialang.org
      (_)     | (_) (_)    |
       _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
      | | | | | | |/ _` |  |
      | | |_| | | | (_| |  |  Version 1.0.0 (2018-08-08)
     _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
    |__/                   |

    ```

*   Type a `]` character to open a "pkg" subshell.

    ```
    (v1.0) pkg>
    ```

*   Install the ErlPort package.

    ErlPorts is not a registered package yet, so it can be installed as
    described in the [Adding unregistered packages](adding-unreg-packages)
    section of the Julia documentation.
    
    In this example we will use our local clone, but you can also specify the
    GitHub URL and branch name (see the documentation section above).

    ```
    (v1.0) pkg> add /local/path/to/ErlPort.jl

       Cloning default registries into /home/hcs/.julia/registries
       Cloning registry General from "https://github.com/JuliaRegistries/General.git"
      Updating registry at `~/.julia/registries/General`
      Updating git-repo `https://github.com/JuliaRegistries/General.git`
       Cloning git-repo `/home/hcs/w/julia/ErlPort.jl`
      Updating git-repo `/home/hcs/w/julia/ErlPort.jl`
     Resolving package versions...
      Updating `~/.julia/environments/v1.0/Project.toml`
      [572bf9c6] + ErlPort v0.4.0 #many-improvements (/home/hcs/w/julia/ErlPort.jl)
      Updating `~/.julia/environments/v1.0/Manifest.toml`
      [572bf9c6] + ErlPort v0.4.0 #many-improvements (/home/hcs/w/julia/ErlPort.jl)
      [2a0f44e3] + Base64
      [8ba89e20] + Distributed
      [b77e0a4c] + InteractiveUtils
      [8f399da3] + Libdl
      [37e2e46d] + LinearAlgebra
      [56ddb016] + Logging
      [d6f4376e] + Markdown
      [9a3f8284] + Random
      [9e88b42a] + Serialization
      [6462fe0b] + Sockets
      [8dfed614] + Test
    ```
    
*   Hit "backspace" to close the "pkg" subshell.

## Usage

The following example shows how to use ErlPort to encode Julia objects into
external term format and decode them from external term format:

```
julia> import ErlPort
[ Info: Precompiling ErlPort [572bf9c6-b013-11e8-0682-13c52dd2789a]

julia> list = [1, 2, 3]
3-element Array{Int64,1}:
 1
 2
 3

julia> encoded = ErlPort.encode(list)
13-element Array{UInt8,1}:
 0x83
 0x6c
 0x00
 0x00
 0x00
 0x03
 0x61
 0x01
 0x61
 0x02
 0x61
 0x03
 0x6a

julia> ErlPort.decode(encoded)
3-element Array{Int64,1}:
 1
 2
 3
```

The contents of the `encoded` byte sequence can be read natively in Erlang:

```
~$ erl
Erlang/OTP 21 [erts-10.0.8] [source] [64-bit] [smp:4:4] [ds:4:4:10]
[async-threads:4] [hipe]

Eshell V10.0.8  (abort with ^G)

% The `Encoded` variable has the exact same bytes as the `encoded` variable in
% the Julia shell above.
1> Encoded = <<"\x83\x6c\x00\x00\x00\x03\x61\x01\x61\x02\x61\x03\x6a">>.
<<131,108,0,0,0,3,97,1,97,2,97,3,106>>

2> List = binary_to_term(Encoded).
[1,2,3]
```

## A note on representation

Sometimes the same data can have multiple representation in External term
format. E.g. both the `<<131,108,0,0,0,3,97,1,97,2,97,3,106>>` and
`<<131,107,0,3,1,2,3>>` byte sequences in External Term Format represent the
`[1,2,3]` list.

As we see in the example above, ErlPort chooses the former representation.
Erlang's `term_to_binary` function chooses the latter:

```
erlang> term_to_binary([1,2,3]).
<<131,107,0,3,1,2,3>>
```

This doesn't cause any problem, this representation is also recognized by
ErlPort:

```
julia> ErlPort.decode(b"\x83\x6b\x00\x03\x01\x02\x03")
3-element Array{UInt8,1}:
 0x01
 0x02
 0x03
```

## Unit tests

*   Start the Julia shell and type a `]` character to open a "pkg" subshell.

    ```
    $ julia
    [...]
    (v1.0) pkg>
    ```

*   Type `test ErlPort`:

    ```
    (v1.0) pkg> test ErlPort   
    Testing ErlPort   
    [...]
    Testing ErlPort tests passed
    ```

## Type Conversions

### Erlang to Julia

| Erlang       | Julia            |
|--------------|------------------|
| `true`       | `true`           |
| `false`      | `false`          |
| `undefined`  | `nothing`        |
| `nan`        | `NaN`            |
| `an_atom`    | `:an_atom`       |
| `3`          | `3`    (Int64)   |
| `3.14`       | `3.14` (Float64) |
| `<<"str">>`  | `b"str"`         |
| `[1,2,3]`    | `[1,2,3]`        |
| `{a,b,c}`    | `(:a,:b,:c)`     |
| `#{1 => 2}`  | `Dict(1 => 2)`   |

### Julia to Erlang

| Julia            | Erlang       |
|------------------|--------------|
| `true`           | `true`       |
| `false`          | `false`      |
| `nothing`        | `undefined`  |
| `NaN`            | `nan`        |
| `:an_atom`       | `an_atom`    |
| `3` (Int64)      | `3`          |
| `3.14` (Float64) |` `3.14       |
| `"str"`          | `<<"str">>`  |
| `b"str"`         | `<<"str">>`  |
| `[1,2,3]`        | `[1,2,3]`    |
| `(:a,:b,:c)`     | `{a,b,c}`    |
| `Dict(1 => 2)`   |`#{1 => 2}`   |

[adding-unreg-packages]: https://docs.julialang.org/en/v1/stdlib/Pkg/index.html#Adding-unregistered-packages-1

