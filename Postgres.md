# Using postgres

I manage most things just simply with files that we execute. The only
odd thing is that I wrote something in crystal to execute the file.

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
