# ErlPort

*A Julia-Erlang module for using the External Term Format from Julia*

Though this module can be used stand-alone, it was originall designed to be
used with the [ErlPort](http://erlport.org/) project, allowing Julia code to
be run from [Erlang](http://www.erlang.org/) and [LFE](http://lfe.io/),
sending its results back as Erlang terms.

## Installation

TBD

## Dev Installation

In the cloned repo, just run the following:

```bash
$ make dev
```

And then:

```bash
$ make test
```

## Usage

TBD

## Detailed Information

### Type Conversions

#### Erlang & LFE to Julia

| Erlang     | LFE        | Julia          |
|------------|------------|----------------|
| true       | 'true      | true           |
| false      | 'false     | false          |
| undefined  | 'undefined | nothing        |
| an_atom    | 'an-atom   | :an_atom       |
| 3.14       | 3.14       | 3.14 (Float64) |
| "str"      | "str"      | b"str"         |
| [1,2,3]    | (1 2 3)    | [1,2,3]        |
| {a,b,c}    | #(a b c)   | (:a,:b,:c)     |

(more to come)

#### Julia to Erlang & LFE

TBD
