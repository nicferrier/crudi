# CRUDi

CRUDi is an attempt to make a DB based Wiki.

The idea is that a database can express the differences necessary in a
web content system; for example, different tables might represent
different types of content, one table for blog posts, another for
project management tickets. The creation of such content requires
different entry forms, so different display and handling.

Tieing all this together is CRUDi's job.

## Git repositories

Wiki, issues (or tickets, or whatever you want to call them) and
source code are the 3 things that CRUDi will handle.

If it's going to be database based how will Git repos be handled?

The answer is that we'll store git repos in PostgreSQL too. We'll do
this through the magic of Linux's FUSE library system.


## Wiki format

The wiki format is JSON. Documents look like this:

```
[{"h1": {"this is a title"},
 {"p": {"this is a paragraph"}]
```

in other words it's just HTML written as JSON objects in an array.

I'll add more examples here as we code for them.


## Installation

We will just make linux executables and also dockers, so you should be
able to run it that way.

CRUDi requires PostgreSQL 9.6.


## Usage

I expect there will be web based admin.


## Development

Hack on it with crystal-lang.

```shell
crystal build src/crudi.cr
```

## Contributing

1. Fork it ( https://github.com/[your-github-name]/crudi/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [nicferrier](https://github.com/nicferrier)  - creator, maintainer
