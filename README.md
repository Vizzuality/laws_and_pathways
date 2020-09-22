# Laws and Pathways backoffice

The backoffice for laws and pathways

## Dependencies:

- Ruby v2.6.3
- Rails v5.2.3
- Node v10
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
