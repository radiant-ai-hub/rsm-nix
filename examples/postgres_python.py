# %% [markdown]
# # PostgreSQL from Python (SQLAlchemy + pandas)
#
# Connect to the workspace-local PostgreSQL, create a table, insert rows, and
# read them back with pandas.
#
# **First start the database** (in a terminal in the workspace):
#
# ```bash
# rsm-pg-start
# ```
#
# The connection uses the `PG*` environment variables the dev shell exports
# (`PGUSER`, `PGPORT`, `PGDATABASE`, `PGHOST`) — local socket, trust auth, no
# password. This is the Nix/direnv Postgres, not the old container one.

# %%
import getpass
import os

from sqlalchemy import create_engine, text
import pandas as pd

user = os.environ.get("PGUSER", getpass.getuser())
port = os.environ.get("PGPORT", "8765")
db = os.environ.get("PGDATABASE", "rsm-msba")

# TCP loopback (works with the workspace-local server started by rsm-pg-start).
url = f"postgresql+psycopg2://{user}@127.0.0.1:{port}/{db}"
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

# %% read it back with pandas
df = pd.read_sql_query("SELECT * FROM films ORDER BY year", con=engine)
print(df)

# %% confirm the server identity (which database/user/port am I really on?)
info = pd.read_sql_query(
    "SELECT current_database() AS db, current_user AS usr, "
    "inet_server_port() AS port, version() AS version",
    con=engine,
)
print(info.T)

# %% cleanup
with engine.begin() as con:
    con.execute(text("DROP TABLE films"))
print("\nPostgreSQL round-trip OK.")
