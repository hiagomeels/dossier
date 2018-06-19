defmodule Dossier.Parser do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      @behaviour Dossier.Parser
    end
  end

  @callback default_opts :: keyword

  @callback check_field(field :: atom, type :: atom, opts :: keyword) :: any

  @callback decode(mod :: module, str :: string) :: {:ok, schema :: map} | {:error, raise :: atom}

  @callback encode(mod :: module, schema :: map) :: {:ok, str :: string} | {:error, raise :: atom}
end
