defmodule Dossier.SchemaTest do
  use ExUnit.Case

  doctest Dossier.Schema

  defmodule ProductSchema do
    use Dossier.Schema

    schema do
      field :id,          :integer
      field :name
      field :description, :string
      field :price,       :float
    end
  end

  test "ProductSchema - schema metadata" do
    assert ProductSchema.__schema__(:delimiter)             == ","
    assert ProductSchema.__schema__(:fields)             == [:id, :name, :description, :price]
  end

  test "ProductSchema - types metadata" do
    assert ProductSchema.__schema__(:type, :id)           == :integer
    assert ProductSchema.__schema__(:type, :name)         == :string
    assert ProductSchema.__schema__(:type, :description)  == :string
    assert ProductSchema.__schema__(:type, :price)        == :float
  end

  test "ProductSchema - sources metadata" do
    assert ProductSchema.__schema__(:field_source, :id)           == :id
    assert ProductSchema.__schema__(:field_source, :name)         == :name
    assert ProductSchema.__schema__(:field_source, :description)  == :description
    assert ProductSchema.__schema__(:field_source, :price)        == :price
  end

  test "ProductSchema - check struct" do
    assert %ProductSchema{}.id == nil
    assert %ProductSchema{}.name == nil
    assert %ProductSchema{}.description == nil
    assert %ProductSchema{}.price == nil
  end

  test "ProductSchema - check string parse" do
    
    assert ProductSchema.parse(nil) == {:error, :invalid_string}
    
    str = "1,apple,used in apple pies,1.5"
    product = ProductSchema.parse(str)

    assert product.id == 1
    assert product.name == "apple"
    assert product.description == "used in apple pies"
    assert product.price == 1.5
  end

  test "ProductSchema - check dump map to string" do
    product = 
      %ProductSchema{
        description: "used in strawberry pies",
        id: 350,
        name: "Strawberry",
        price: 10.0
      }
      
    str = "350,Strawberry,used in strawberry pies,10.0"
    
    assert ProductSchema.dump(product) == str
  end

  defmodule CostumerSchema do
    use Dossier.Schema

    @delimiter "|"

    schema do
      field :id,          :integer
      field :name
    end
  end

  test "schema metadata" do
    assert CostumerSchema.__schema__(:delimiter)             == "|"
    assert CostumerSchema.__schema__(:fields)             == [:id, :name]
  end

  test "types metadata" do
    assert CostumerSchema.__schema__(:type, :id)           == :integer
    assert CostumerSchema.__schema__(:type, :name)         == :string
  end

  test "check struct" do
    assert %CostumerSchema{}.id == nil
    assert %CostumerSchema{}.name == nil
  end

  test "CostumerSchema - check parse string" do
    assert CostumerSchema.parse(nil) == {:error, :invalid_string}
    
    str = "171|John Due"
    customer = CostumerSchema.parse(str)

    assert customer.id == 171
    assert customer.name == "John Due"
  end

  test "CostumerSchema - check dump schema to string" do
    str = "171|John Due"
    customer = 
      %CostumerSchema{
        id: 171,
        name: "John Due"
      }

    assert CostumerSchema.dump(customer) == str
  end
end