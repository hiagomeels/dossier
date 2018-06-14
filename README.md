# Dossier
Dossier the way to parse string in schemas and vice versa.

# Examples
## Delimited strings
### Define a schema
```elixir
defmodule ProductSchema do
  use Dossier.Schema
  
  @delimiter "|" # optional (default delimiter is a "," [comma])

  schema do
    field :id,          :integer
    field :name
    field :description, :string
    field :price,       :float
  end
end
```
### Parse a string into a ProductSchema
```elixir
str = "1|apple|used in apple pies|1.5"
product = ProductSchema.parse(str)

iex> %ProductSchema{
  description: "used in apple pies",
  id: 1,
  name: "apple",
  price: 1.5
}
```
### Parse a Schema into string
```elixir
%ProductSchema{
  description: "used in strawberry pies",
  id: 350,
  name: "Strawberry",
  price: 10
}
|> ProductSchema.dump

iex> "350|Strawberry|used in strawberry pies|10"

```

## Roadmap
- [x] Create a schema mapping equals to Ecto =]
- [x] Create a delimited string reader (parse :: str -> schema)
- [x] Create a delimited string dump (dump(str) :: schema -> str)
- [ ] Create a fixed length string reader (parse :: str -> schema)
- [ ] Create a fixed length string dump (dump(str) :: schema -> str) 
- [ ] Create a system for suport a custom types, parses, formaters

# Contribute
Just fork the repo, make your change, and send me a pull request.

Or, feel free to file and issue and start a discussion about a new feature you have in mind.