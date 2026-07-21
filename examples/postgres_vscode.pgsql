/*
  -- PostgreSQL test for VS Code (workspace-local Nix/direnv database)
  -- =================================================================

  -- 1. Start the database first, in a workspace terminal:

  --    rsm-pg-start

  -- 2. Install the PostgreSQL VS Code extension by Chris Kolkman
  -- (extension id: ckolkman.vscode-postgres).

  -- 3. Add a connection (PostgreSQL Explorer -> "+"), using:

      -- host     : 127.0.0.1
      -- user     : <your username>      (the output of:  whoami)
      -- password : (leave blank — local "trust" auth)
      -- port     : (see output from pg)
      -- database : Northwind (or WestCoastImporters)
      -- display  : Northwind (or WestCoastImporters)

  -- The user is your OS login name (e.g. the result of `id -un`). This is a practice database for learning purposes so there is no password.

  -- 4. Click "Select Postgres Server" in the bottom VS Code status bar, choose the Northwind (or WestCoastImporters) connection, then run the statements below with F5 (or right-click -> "Run Query").
*/

/* choose Northwind as the active server and check if the below statement works */
SELECT * FROM "products" LIMIT 5;

/* choose WestCoastImporter as the active server and check if the below statement works */
-- SELECT * FROM "buyinggroup" LIMIT 5;
