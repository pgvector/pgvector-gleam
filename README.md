# pgvector-gleam

[pgvector](https://github.com/pgvector/pgvector) examples for Gleam

Supports [pog](https://github.com/lpil/pog)

[![Build Status](https://github.com/pgvector/pgvector-gleam/actions/workflows/build.yml/badge.svg)](https://github.com/pgvector/pgvector-gleam/actions)

## Getting Started

Follow the instructions for your database library:

- [pog](#pog)

## pog

Enable the extension

```gleam
let assert Ok(_) =
  pog.query("CREATE EXTENSION IF NOT EXISTS vector")
  |> pog.execute(db)
```

Create a table

```gleam
let assert Ok(_) =
  pog.query("CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")
  |> pog.execute(db)
```

Insert vectors

```gleam
let assert Ok(_) =
  pog.query("INSERT INTO items (embedding) VALUES ($1::text::vector), ($2::text::vector)")
  |> pog.parameter(pog.text("[1,2,3]"))
  |> pog.parameter(pog.text("[4,5,6]"))
  |> pog.execute(db)
```

Get the nearest neighbors

```gleam
let assert Ok(response) =
  pog.query("SELECT id FROM items ORDER BY embedding <-> $1::text::vector LIMIT 5")
  |> pog.parameter(pog.text("[3,1,2]"))
  |> pog.returning(dynamic.element(0, dynamic.int))
  |> pog.execute(db)
```

Add an approximate index

```gleam
let assert Ok(_) =
  pog.query("CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
  |> pog.execute(db)
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](src/pgvector.gleam)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/pgvector/pgvector-gleam/issues)
- Fix bugs and [submit pull requests](https://github.com/pgvector/pgvector-gleam/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/pgvector/pgvector-gleam.git
cd pgvector-gleam
createdb pgvector_gleam_test
gleam run
```
