const express = require("express")
const db = require("knex")({
  client: 'pg',
  connection: process.env.DATABASE_URL,
  searchPath: ['public'],
})

const PORT = Number(process.env.PORT || "3000")

const app = express()

app.get("/", async (req, res) => {
  const { rows } = await db.raw(`
    SELECT
      'Hello, world!' as greeting,
      current_timestamp as time
  `)
  res.status(200).json(rows[0])
})

app.listen(PORT)
