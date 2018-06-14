defmodule Dossier.Schema do
 @doc false
 defmacro __using__(_) do
    quote do
      import Dossier.Schema, only: [schema: 1]

      @delimiter ","
      
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :struct_fields, accumulate: true)
    end
  end

  defmacro schema([do: block]) do
    __schema__(block)
  end

  defp __schema__(block) do

    prelude =
      quote do      
        try do
          import Dossier.Schema
          unquote(block)
        after
          :ok
        end
      end

    postlude =
      quote unquote: false do
        delimiter   = @delimiter
        fields      = @fields |> Enum.reverse
        
        defstruct @struct_fields

        def __schema__(:delimiter), do: unquote(delimiter)
        def __schema__(:fields), do: unquote(Enum.map(fields, &elem(&1, 0)))

        for {field, type} <- fields do
          def __schema__(:type, unquote(field)), do: unquote(type)
          def __schema__(:field_source, unquote(field)), do: unquote(field)
        end

        def parse(str), do: Dossier.Schema.__parse__(__MODULE__, str)
        def dump(str), do: Dossier.Schema.__dump__(__MODULE__, str)

        Module.eval_quoted __ENV__, []
      end
    quote do
      unquote(prelude)
      unquote(postlude)
    end  
  end
  
  # API

  @doc """
    Defines a field on the schema given a name and type.
  """
  defmacro field(name, type \\ :string, opts \\ []) do
    quote do
      Dossier.Schema.__field__(__MODULE__, unquote(name), unquote(type), unquote(opts))
    end
  end

  ## Methods
  @doc """
    Parses a string into Schema
  """
  def parse(_str), do: nil

  @doc false
  def __parse__(mod, str) when is_binary(str) do
    struct    = mod.__struct__
    delimiter = mod.__schema__(:delimiter)
    fields    = mod.__schema__(:fields)
    values    = str |> String.split(delimiter)

    map =
      fields
      |> Enum.with_index
      |> Enum.map(fn {field, idx} -> 
        type  = mod.__schema__(:type, field)
        value = Enum.at(values, idx)
        
        {field, parse_field(value, type)}
      end)
      |> Enum.into(%{})
    
    Map.merge(struct, map)
  end
  def __parse__(mod, _), do: {:error, :invalid_string}

  defp parse_field(value, :string), do: value
  defp parse_field(value, :integer) do
    value
    |> Integer.parse
    |> case do
      {int, _} -> int
      _ -> :invalid_parse
    end
  end
  defp parse_field(value, :float) do
    value
    |> Float.parse
    |> case do
      {float, _} -> float
      _ -> :invalid_parse
    end
  end

  @doc """
    Dump a Schema into string
  """
  def dump(_schema), do: false

  @doc false
  def __dump__(mod, schema) do 
    delimiter = mod.__schema__(:delimiter)
    fields    = mod.__schema__(:fields)
    
    fields
    |> Enum.map(fn field ->  
      schema
      |> Map.has_key?(field)
      |> case do
        true -> Map.get(schema, field) |> to_string
        _ -> raise ArgumentError, "then field :#{inspect field} not found in schema"
      end
    end)
    |> Enum.join(delimiter)
  end


  ## Callbacks
  @doc false
  def __field__(mod, name, type, opts) do
    check_field_type!(name, type, opts)
    define_field(mod, name, type, opts)
  end

  # Private
  @types [:string, :integer, :float]
  defp check_field_type!(_name, type, _opts) when type in @types, do: :ok
  defp check_field_type!(name, type, _opts) do
    raise ArgumentError, "invalid type #{type} for field #{inspect name}."
  end

  defp define_field(mod, name, type, opts) do    
    put_struct_field(mod, name)
    Module.put_attribute(mod, :fields, {name, type})
    Module.put_attribute(mod, :fields_opts, {name, type, opts})
  end

  defp put_struct_field(mod, name) do
    fields = Module.get_attribute(mod, :struct_fields)

    if List.keyfind(fields, name, 0) do
      raise ArgumentError, "field #{inspect name} is already set on schema"
    end

    Module.put_attribute(mod, :struct_fields, {name, nil})
  end
end