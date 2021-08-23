Erlang psql(1) CLI
==================

```
usage: epsql [-h host][-p port][-P pass][-U user] [database]

-h host         host to connect to; default "127.0.0.1"
-p port         port number to connect to; default "5432"
-P pass         user password
-U user         user to connect as; default "$USER"
```

A simple `psql(1)` like CLI tool that reads standard input for SQL statements passing them on to the connected PostgreSQL server.
For example:

```
$ echo "CREATE DATABASE black;" |  epsql -U postgres
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


Copyright
---------

Copyright 2021 by Anthony Howe.  All rights reserved.


MIT License
-----------

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
