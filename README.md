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

### Run the server

`yarn start'` and access the project on `http://localhost:3000`

### Run the tests

`yarn test`

## Docker

TODO

## Configuration

### Google Cloud Storage

Credential key JSON file is encoded using base64 algorithm and could be placed either in `GCS_CREDENTIALS` env variable or
for staging/production in credentials.yml.enc file.


To encode credentials file
```
base64 -w 0 file_name.json
```

## API
