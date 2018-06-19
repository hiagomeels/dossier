defmodule Dossier.Parser.Delimited do
  @moduledoc """
    Parser used in delimited strings
  """

  use Dossier.Parser

  def default_opts, do: [delimiter: ","]
  def check_field(_field, _type, _opts), do: :ok

  def decode(mod, <<str::bytes>>) do
    delimiter = mod.__opts__(:delimiter)
    values = str |> String.split(delimiter)

    schema =
      :fields
      |> mod.__schema__
      |> Enum.with_index()
      |> Enum.map(fn {field, idx} ->
        type = mod.__schema__(:type, field)
        value = Enum.at(values, idx)

        {field, decode_field(value, type)}
      end)
      |> Enum.into(%{})

    {:ok, schema}
  end

  def decode(mod, _), do: {:error, :invalid_string}

  def encode(mod, %{} = schema) do
    delimiter = mod.__opts__(:delimiter)
    fields = mod.__schema__(:fields)

    str =
      fields
      |> Enum.map(fn field ->
        schema
        |> Map.has_key?(field)
        |> case do
          true -> schema |> Map.get(field) |> to_string
          _ -> ""
        end
      end)
      |> Enum.join(delimiter)

    {:ok, str}
  end

  def encode(mod, _), do: {:error, :invalid_schema}

  defp decode_field(value, :string), do: value

  defp decode_field(value, :integer) do
    value
    |> Integer.parse()
    |> case do
      {i, _} -> i
      _ -> value
    end
  end

  defp decode_field(value, :float) do
    value
    |> Float.parse()
    |> case do
      {f, _} -> f
      _ -> value
    end
  end
end
