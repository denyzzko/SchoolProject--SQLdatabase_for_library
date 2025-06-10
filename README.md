# Library Database Project

This project contains a SQL-based implementation of a relational database system for managing a library.

## Description

The project defines the schema for a library system, including tables for readers, employees, books, journals, authors, genres, reservations, loans, and penalties. It also includes sequences for generating primary keys and indexes to optimize queries.

The SQL script is intended to be run in an Oracle SQL environment (compatible with Oracle Database systems).

## Files

- `src/library_database.sql` – Main SQL script containing all table definitions, constraints, sequences, and indexes.
- `database_diagram.pdf` – Entity-relationship diagram of the database.
- `documentation.pdf` – Project documentation and design explanation.

## Features

- Entity relationships for books, authors, genres, and users
- Normalized relational schema
- Referential integrity with foreign keys
- Drop and create logic for re-deployable scripts
- Includes indexes and sequences for efficient operation

## Usage

1. Open the SQL script in an Oracle-compatible environment.
2. Execute the script to create the database schema.
3. Use the schema to insert, query, and manage library-related data.
