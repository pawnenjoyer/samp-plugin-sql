# sql.so ELF64 + MariaDB Connector/C

Fork of [udan11/samp-plugin-sql](https://github.com/udan11/samp-plugin-sql) v2.6 for official **x86_64 open.mp**.

Pawn natives stay 2.6 (`sql_query`, `sql_queryEx`, `QUERY_CACHED` / `QUERY_THREADED`). Load as SA-MP legacy plugin:

```
plugins/sql.so
pawn.legacy_plugins: ["sql"]
```

## Build (Ubuntu x86_64, same glibc as VDS)

```bash
sudo apt-get install -y g++ make libmariadb-dev pkg-config
make
file bin/sql.so
ldd bin/sql.so
```

`libmariadb-dev` is the **client** Connector/C. It does not install a MariaDB server.

On a host that already runs **MySQL 8**, `apt install libmariadb-dev` also pulls `mariadb-common` and can steal `/etc/mysql/my.cnf` via `update-alternatives`. After the build, restore:

```bash
update-alternatives --set my.cnf /etc/mysql/mysql.cnf
```

Prefer a Connector/C tarball in `vendor/` on the next rebuild so apt never touches `my.cnf`.

Ship `libmariadb.so.3` next to `sql.so` if the host has no package, or rely on distro `libmariadb3`. RPATH is `$ORIGIN`.

## What changed vs upstream

- Dropped `-m32` and bundled `lib/mysql/libmysql.so` (2013).
- Headers: MariaDB Connector/C. Vendored `include/mysql` renamed so it cannot shadow `mysql.h`.
- SDK: `amx2.h` + `amxplugin2.cpp` (Dan `amx_GetCString` / `amx_SetCString`).
- `MYSQL_OPT_RECONNECT` uses `my_bool` as `char` (`1`), not C++ `true`.

## Do not

- Put this `.so` in `/opt/samp`.
- Load it on i686 omp `:1111` (wrong ELF class).
- Enable BlueG `mysql.so` beside it.
