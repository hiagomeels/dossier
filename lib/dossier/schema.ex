defmodule Dossier.Schema do
  @moduledoc """
  Defines a schema.

  An Dossier schema is used to map any string to Elixir struct.

  ## Example

        defmodule MySchema do
          use Dossier.Schema

          parser Dossier.Parser.Delimited

          schema do
            field :id, :integer
            field :name, :string
          end
        end

  """
  defmacro __using__(_) do
    quote do
      import Dossier.Schema, only: [parser: 1, parser: 2, schema: 1]

      @parser Dossier.Parser.Delimited

      Module.put_attribute(__MODULE__, :opts, [])
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :struct_fields, accumulate: true)
    end
  end

  @doc """
  Defines a parser used to encode/decode a strings and structs.

  Default Parser is a Dossier.Parser.Delimited with defaults opts;
  """
  defmacro parser(parser, opts \\ []) do
    quote do
      parser = unquote(parser)

      opts =
        parser.default_opts()
        |> Keyword.merge(unquote(opts))

      Module.put_attribute(__MODULE__, :parser, parser)
      Module.put_attribute(__MODULE__, :opts, opts)
    end
  end

  @doc """
  Defines a schema used to map any string to Elixir struct.
  """
  defmacro schema(do: block) do
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
        defstruct Module.get_attribute(__MODULE__, :struct_fields)

        opts = __MODULE__ |> Module.get_attribute(:opts)
        fields = __MODULE__ |> Module.get_attribute(:fields) |> Enum.reverse()
        parser = __MODULE__ |> Module.get_attribute(:parser)

        def __opts__, do: unquote(opts)
        def __parser__, do: unquote(parser)
        def __schema__(:fields), do: unquote(Enum.map(fields, &elem(&1, 0)))

        for {opt, value} <- opts do
          def __opts__(unquote(opt)), do: unquote(value)
        end

        for {field, type, opts} <- fields do
          def __schema__(:type, unquote(field)), do: unquote(type)
          def __schema__(:field_source, unquote(field)), do: unquote(field)
          def __schema__(:opts, unquote(field)), do: unquote(opts)
        end

        def decode(str), do: Dossier.Schema.__decode__(__MODULE__, str)
        def decode!(str), do: Dossier.Schema.__decode__!(__MODULE__, str)

        def encode(schema), do: Dossier.Schema.__encode__(__MODULE__, schema)
        def encode!(schema), do: Dossier.Schema.__encode__!(__MODULE__, schema)

        Module.eval_quoted(__ENV__, [])
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

  ## Callbacks
  def __decode__(mod, str) do
    parser = mod.__parser__()

    mod
    |> parser.decode(str)
    |> case do
      {:ok, map} -> {:ok, Map.merge(mod.__struct__(), map)}
      err -> err
    end
  end

  def __decode__!(mod, str) do
    mod
    |> __decode__(str)
    |> case do
      {:ok, map} -> map
      _ -> raise RuntimeError, "An error occurred when encode the string"
    end
  end

  def __encode__(mod, schema) do
    parser = mod.__parser__()
    parser.encode(mod, schema)
  end

  def __encode__!(mod, schema) do
    mod
    |> __encode__(schema)
    |> case do
      {:ok, str} -> str
      _ -> raise RuntimeError, "An error occurred when decode the string"
    end
  end

  @doc false
  def __field__(mod, name, type, opts) do
    parser = Module.get_attribute(mod, :parser)

    parser.check_field(name, type, opts)
    check_field_type!(name, type, opts)
    define_field(mod, name, type, opts)
  end

  # Private
  @types [:string, :integer, :float]
  defp check_field_type!(_name, type, _opts) when type in @types, do: :ok

  defp check_field_type!(name, type, _opts) do
    raise ArgumentError, "invalid type #{type} for field #{inspect(name)}."
  end

  defp define_field(mod, name, type, opts) do
    put_struct_field(mod, name)
    Module.put_attribute(mod, :fields, {name, type, opts})
  end

  defp put_struct_field(mod, name) do
    fields = Module.get_attribute(mod, :struct_fields)

    if List.keyfind(fields, name, 0) do
      raise ArgumentError, "field #{inspect(name)} is already set on schema"
    end

    Module.put_attribute(mod, :struct_fields, {name, nil})
  end
end
