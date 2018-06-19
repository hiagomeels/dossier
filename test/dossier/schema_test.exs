defmodule Dossier.SchemaTest do
  use ExUnit.Case

  doctest Dossier.Schema

  defmodule ProductSchema do
    use Dossier.Schema

    schema do
      field :id, :integer
      field :name, :string
      field :price, :float
    end
  end

  test "ProductSchema - schema metadata" do
    assert ProductSchema.__schema__(:fields) == [:id, :name, :price]
  end

  test "ProductSchema - types metadata" do
    assert ProductSchema.__schema__(:type, :id) == :integer
    assert ProductSchema.__schema__(:type, :name) == :string
    assert ProductSchema.__schema__(:type, :price) == :float
  end

  test "ProductSchema - sources metadata" do
    assert ProductSchema.__schema__(:field_source, :id) == :id
    assert ProductSchema.__schema__(:field_source, :name) == :name
    assert ProductSchema.__schema__(:field_source, :price) == :price
  end

  test "ProductSchema - check struct" do
    product = %ProductSchema{}

    assert product.id == nil
    assert product.name == nil
    assert product.price == nil
  end
end
