/*
  PostgreSQL test for VS Code (workspace-local Nix/direnv database)
  =================================================================

  1. Start the database first, in a workspace terminal:

         rsm-pg-start

  2. Install the PostgreSQL VS Code extension by Chris Kolkman
     (extension id: ckolkman.vscode-postgres).

  3. Add a connection (PostgreSQL Explorer -> "+"), using:

         host     : 127.0.0.1
         user     : <your username>      (the output of:  whoami)
         password : (leave blank — local "trust" auth)
         port     : 8765
         database : rsm-msba
         display  : rsm-msba

     The user is your OS login name (e.g. the result of `id -un`), NOT
     "jovyan" — that was the old Docker image. There is no password.

  4. Click "Select Postgres Server" in the bottom VS Code status bar, choose
     the rsm-msba connection, then run the statements below with F5
     (or right-click -> "Run Query").
*/

-- Confirm WHICH server you are connected to (port 8765 + your username = the
-- workspace-local Nix database, not /opt/base-uv or a container).
SELECT current_database() AS db,
       current_user       AS usr,
       inet_server_port() AS port;

-- Create a small table, insert rows, and read them back.
DROP TABLE IF EXISTS films;
CREATE TABLE films (title text, director text, year int);
INSERT INTO films (title, director, year) VALUES
  ('Dune: Part Two', 'Denis Villeneuve', 2024),
  ('Oppenheimer',    'Christopher Nolan', 2023);

SELECT * FROM films ORDER BY year;

-- Clean up (optional)
DROP TABLE films;
