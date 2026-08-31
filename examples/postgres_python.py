# %% [markdown]
# # PostgreSQL from Python (SQLAlchemy + Polars)
#
# Connect to the workspace-local PostgreSQL, create a table, insert rows, and
# read them back with Polars.
#
# **First start the database** (in a terminal in the workspace):
#
# ```bash
# rsm-pg-start
# ```
#
# The connection uses the `PG*` environment variables the dev shell exports
# (`PGUSER`, `PGPORT`, `PGDATABASE`, `PGHOST`) — a private Unix socket with peer
# auth, no password and no TCP. On a shared server `PGPORT` is **per-user**, so
# don't hard-code it; read everything from the environment as below.

# %%
import getpass
import os

from sqlalchemy import create_engine, text
import polars as pl

user = os.environ.get("PGUSER", getpass.getuser())
port = os.environ.get("PGPORT")  # names the socket file; set per-user, don't hard-code
db = os.environ.get("PGDATABASE", "rsm-msba")
host = os.environ.get("PGHOST")  # the private socket directory (peer auth, no TCP)

# Connect over the Unix socket (host is a directory path). This is the only
# transport on a shared server — there is no TCP listener to reach.
url = f"postgresql+psycopg2://{user}@/{db}?host={host}&port={port}"
print("connecting to:", url)
engine = create_engine(url)

# %% create a table and insert a couple of rows
with engine.begin() as con:
    con.execute(text("DROP TABLE IF EXISTS films"))
    con.execute(text("CREATE TABLE films (title text, director text, year int)"))
    con.execute(
        text("INSERT INTO films (title, director, year) VALUES (:t, :d, :y)"),
        [
            {"t": "Dune: Part Two", "d": "Denis Villeneuve", "y": 2024},
            {"t": "Oppenheimer", "d": "Christopher Nolan", "y": 2023},
        ],
    )

# %% read it back with Polars
with engine.connect() as con:
    df = pl.read_database("SELECT * FROM films ORDER BY year", connection=con)
print(df)

# %% confirm the server identity (which database/user/port am I really on?)
with engine.connect() as con:
    info = pl.read_database(
        "SELECT current_database() AS db, current_user AS usr, "
        "inet_server_port() AS port, version() AS version",
        connection=con,
    )
print(info)

# %% cleanup
with engine.begin() as con:
    con.execute(text("DROP TABLE films"))
print("\nPostgreSQL round-trip OK.")
