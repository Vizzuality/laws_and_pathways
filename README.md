# Laws and Pathways backoffice

The backoffice for laws and pathways

## Dependencies:

- Ruby v2.7.2
- Rails v6.0.3
- Node v14
- PostgreSQL v11

## Local installation

These are the steps to run the project locally:

### Installing ruby dependencies

On the project's root run `bundle install`.

### Installing npm dependencies

`yarn`

### Database

#### Create database schema

`bundle exec rails db:setup` to setup the database

### Setting up local subdomains

This project contains two different websites and admin panel. That's why to make it work we need to make changes to /etc/hosts in development env

Add those 2 entries to your `/etc/hosts` file

```
127.0.0.1        tpi.localhost
127.0.0.1        cclow.localhost
```

### Run the server

`yarn start'` and access the project on `http://localhost:3000`

### Run the tests

`yarn test`

#### System tests

For speed and simplicity to not have to create complicated scenarios using factories, for system testing we are always loading complete db dump.

DB was created by seeding the database and its stored in `db/test-dump.sql` file.
To recreate dump use dedicated rake task `RAILS_ENV=test bin/rails test:db_dump`

### Run linters

`yarn lint`
`yarn lint:rails`
`yarn lint:js`

## Docker

TODO

## Configuration

### Google Cloud Storage

Credential key JSON file is stored in `config/secrets` directory. You can override file by setting `GCS_CREDENTIALS_FILE` env variable, all files
must be stored in `config/secrets` directory.

Be sure to never commit credentials file!

## API

## Flags Sourced from

 * [FlagKit](https://github.com/madebybowtie/FlagKit)

## MISC

### Model annotations

To annotate models run

`bundle exec annotate --models`
