import envoy
import gleam/dynamic
import gleam/io
import gleam/string
import pog

pub fn main() {
  let assert Ok(user) = envoy.get("USER")
  let db =
    pog.default_config()
    |> pog.database("pgvector_gleam_test")
    |> pog.user(user)
    |> pog.connect

  let assert Ok(_) =
    pog.query("CREATE EXTENSION IF NOT EXISTS vector") |> pog.execute(db)

  let assert Ok(_) = pog.query("DROP TABLE IF EXISTS items") |> pog.execute(db)

  let assert Ok(_) =
    pog.query(
      "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))",
    )
    |> pog.execute(db)

  let assert Ok(_) =
    pog.query(
      "INSERT INTO items (embedding) VALUES ($1::text::vector), ($2::text::vector), ($3::text::vector)",
    )
    |> pog.parameter(pog.text("[1,1,1]"))
    |> pog.parameter(pog.text("[2,2,2]"))
    |> pog.parameter(pog.text("[1,1,2]"))
    |> pog.execute(db)

  let assert Ok(response) =
    pog.query(
      "SELECT id FROM items ORDER BY embedding <-> $1::text::vector LIMIT 5",
    )
    |> pog.parameter(pog.text("[1,1,1]"))
    |> pog.returning(dynamic.element(0, dynamic.int))
    |> pog.execute(db)
  io.println(string.inspect(response.rows))

  let assert Ok(_) =
    pog.query("CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
    |> pog.execute(db)
}
