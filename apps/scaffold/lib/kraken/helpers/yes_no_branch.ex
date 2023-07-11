defmodule Scaffold.Kraken.Helpers.YesNoBranch do
  def yes_or_no(args, path) do
    if get_in(args, path) do
      "yes"
    else
      "no"
    end
  end
end
