defmodule Dossier.Parser.DelimitedTest do
  use ExUnit.Case

  doctest Dossier.Parser.Delimited

  defmodule ProductSchema do
    use Dossier.Schema

    parser Dossier.Parser.Delimited

    schema do
      field :id, :integer
      field :name, :string
      field :price, :float
    end
  end

  test "ProductSchema - schema metadata" do
    assert ProductSchema.__opts__(:delimiter) == ","
  end

  test "ProductSchema - check string decode" do
    assert ProductSchema.decode(nil) == {:error, :invalid_string}

    str = "1,apple,1.5"

    assert {:ok, _} = ProductSchema.decode(str)

    {:ok, product} = ProductSchema.decode(str)

    assert product.id == 1
    assert product.name == "apple"
    assert product.price == 1.5
  end

  test "ProductSchema - check string decode!" do
    msg = "An error occurred when encode the string"

    assert_raise RuntimeError, msg, fn ->
      ProductSchema.decode!(nil)
    end

    str = "1,apple,1.5"
    product = ProductSchema.decode!(str)

    assert product.id == 1
    assert product.name == "apple"
    assert product.price == 1.5
  end

  test "ProductSchema - check encode map to string" do
    assert {:error, :invalid_schema} = ProductSchema.encode(nil)

    product = %ProductSchema{
      id: 350,
      name: "Strawberry",
      price: 10.0
    }

    assert {:ok, "350,Strawberry,10.0"} = ProductSchema.encode(product)
  end
end
