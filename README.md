Erlang psql(1) CLI
==================

```
usage: epsql [-v][-h host][-p port][-t ms][-P pass][-U user] [database]

-h host         host to connect to; default "127.0.0.1"
-p port         port number to connect to; default "5432"
-t ms           connection timeout in milliseconds; default "5000"
-P pass         user password
-U user         user to connect as; default "$USER"
```

A simple `psql(1)` like CLI tool that reads standard input for SQL statements passing them on to the connected PostgreSQL server.

### Create A Database

```
$ echo "CREATE DATABASE black;" | epsql -U postgres
$ epsql -U postgres black <<EOT
CREATE TABLE bart (
  id SERIAL,
  name VARCHAR(32),
  colour VARCHAR(8)
);
CREATE INDEX bart ON bart(name);
EOT
$
```

### List Databases

```
$ echo "SELECT datname FROM pg_database;" | epsql -U postgres
```
Or
```
$ echo '\l' | epsql -U postgres
```

### List Datbase Tables

```
$ epsql -U postgres black <<EOT
SELECT tablename FROM pg_catalog.pg_tables WHERE
  schemaname != 'pg_catalog' AND
  schemaname != 'information_schema';
EOT
$
```
Or
```
$ echo '\dt' | epsql -U postgres black
```

### List Table Schema

```
$ epsql -U postgres black <<EOT
SELECT column_name, data_type, character_maximum_length
  FROM information_schema.columns WHERE table_name = 'bart';
EOT
$
```
Or
```
$ echo '\d bart' | epsql -U postgres black
```

### Quit (noop)

```
$ echo '\q' | epsql -U postgres
```


Copyright
---------

Copyright 2021, 2022 by Anthony Howe.  All rights reserved.


MIT License
-----------

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
