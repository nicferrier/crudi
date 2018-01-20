# Using postgres

I manage most things just simply with files of sql that are executed.
The only odd thing is that I wrote something in crystal to execute the
file.


## Setting up clusters

One postgres is easy. But here's what I did to set it up.

```
$ sudo apt-get install postgresql-9.6
$ sudo su - postgres -c 'createuser nicferrier' ## My user
$ sudo su - postgres -c 'createuser crudi'      ## Our db user
$ sudo su - postgres -c 'createdb -O crudi crudi'
```

Setting up the second cluster is more complicated. I'm using ubuntu so
it goes like this:

```
$ sudo pg_createcluster 9.6 second 
$ sudo pg_ctlcluster 9.6 second start           ## creates it using port 5433
$ sudo su - postgres -c 'createuser -p 5433 nicferrier'
$ sudo su - postgres -c 'createuser -p 5433 crudi'
$ sudo su - postgres -c 'createdb -p 5433 -O crudi crudi'
```

Third and fourth clusters can follow on from there.


## Replication

We use trigger based replication.


### Avoiding split brain

All unlogged tables, possibly a temp table

For each server that we know about we add a table X${server-name}, eg:

crudi A -> server A

crudi B -> server B

server A    server B
table XA     table XA
table XB      table XB


crudi A can:

* write a change to server A into table XA and wait for sync commit
 * since we do sync replication each commit must arrive on the other side
 * if the txn fails then we notice
* monitor all other "X" tables for updates

if crudi A sees writes going to XA but no write arriving on another
table then we might have a split brain.

