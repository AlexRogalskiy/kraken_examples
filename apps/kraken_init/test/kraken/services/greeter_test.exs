defmodule KrakenInit.Services.GreeterTest do
  use ExUnit.Case

  @kraken_folder Path.expand("../../../../lib/kraken", __ENV__.file)

  def read_definition(path) do
    File.read!("#{@kraken_folder}/#{path}")
  end

  setup do
    {:ok, "greeter"} = Octopus.define(read_definition("services/greeter.json"))
    {:ok, _state} = Octopus.start("greeter")

    on_exit(fn -> Octopus.delete("greeter") end)
  end

  test "greet" do
    assert {:ok, %{"message" => "Hello, Anton!"}} =
             Octopus.call("greeter", "greet", %{"name" => "Anton"})
  end

  test "no_greet" do
    assert {:ok, %{"message" => "I've already said hello to you, Anton."}} =
             Octopus.call("greeter", "no_greet", %{"name" => "Anton"})
  end
end
