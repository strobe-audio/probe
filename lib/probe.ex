defmodule Probe do
  @moduledoc """
  Provides simple print-style debugging macros.

  Instead of attempting to debug your code using inline placements of
  `IO.inspect`, e.g.

      def some_func, do: :some_value

      case some_func() |> IO.inspect do
        # case handling
      end

  you instead use one of Probe's macros:

      require Probe

      case some_func() |> Probe.i do
        # case handling
      end

  this will do the same as IO.inspect, that is pipe the result of `some_func()`
  to standard out and return it, but will also label the output with the source
  of the value, e.g. in this case it will output:

      some_func() :some_value

  and use ANSI escape sequences to colour the label (if supported, i.e.
  `IO.ANSI.enabled?()` returns `true`)

  If you want, you can provide a custom label for the value:

      some_func() |> Probe.i("what is this?")
      what is this? :some_value
      :some_value
      # or
      %{some: :value} |> Probe.i(:some)
      :some %{some: :value}
      %{some: :value}

  This gives the convenience of the IO.inspect insertion style of debugging but
  allows you to map results to debugging statements through the use of the
  labels.

  If you want to highlight specific debugging statements to make them easier to
  pick-out then use one of the provided style macros, e.g.:

      some_func() |> Probe.red()
      some_func() |> Probe.green()
      some_func() |> Probe.reverse() # equivalent to Probe.i, Probe.d
      some_func() |> Probe.white_bg()
      # etc

  ## Disabling

  Since Probe is built as a set of macros, if you disable it using:

  ```elixir
  config :probe, disabled: true
  ```

  in (say) `config/prod.exs` then the debugging code with be completely removed
  at compile time and the statement:

      calculate() |> Probe.red()

  will compile to the equivalent of calling `calculate()` on its own.

  """

  @default_style Application.get_env(:probe, :default_style, :reverse)

  @style_names [
    {:d, @default_style},
    {:i, @default_style},
    {:red_bg, :red_background},
    {:green_bg, :green_background},
    {:yellow_bg, [:yellow_background, :black]},
    {:blue_bg, :blue_background},
    {:magenta_bg, :magenta_background},
    {:cyan_bg, [:cyan_background, :black]},
    {:white_bg, [:white_background, :black]},
    :reverse,
    :bright,
    :red, :green, :yellow, :blue, :magenta, :cyan, :white,
  ]

  @styles Enum.map(@style_names, fn
    {style, ansi_style} ->
      {style, ansi_style}
    ansi_style ->
      {ansi_style, ansi_style}
  end)


  for {name, ansi_style} <- @styles do
    @doc """
    A debugging macro that outputs debugging information highlighed using
    the `IO.ANSI` style `#{inspect ansi_style}`.

        some_func() |> Probe.#{name}()      # => " some_func() <value>"
        some_func() |> Probe.#{name}(:func) # => " :func <value>"
        Probe.#{name}(some_func(), :tag)    # => " :tag <value>"

    """
    defmacro unquote(name)(expression, label \\ nil) do
      disabled = Application.get_env(:probe, :disabled, false)
      if disabled do
        expression
      else
        quoted_debug(expression, label, unquote(ansi_style))
      end
    end
  end

  defp quoted_debug(expression, label, style) do
    opts = Application.get_env(:probe, :inspect, [pretty: true])
    tag = IO.ANSI.format_fragment([
      style, " ", label_string(expression, label), " ", :reset, " "
    ]) |> IO.iodata_to_binary
    quote do
      result = unquote(expression)
      IO.puts([unquote(tag), inspect(result, unquote(opts))])
      result
    end
  end

  defp label_string(expression, label) do
    cond do
      is_nil(label) -> Macro.to_string(expression)
      is_atom(label) -> inspect(label)
      true -> to_string(label)
    end
  end
end
