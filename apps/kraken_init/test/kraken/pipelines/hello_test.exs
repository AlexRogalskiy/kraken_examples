defmodule KrakenInit.Pipelines.Hello.Test do
  use ExUnit.Case

  @kraken_folder Path.expand("../../../../lib/kraken", __ENV__.file)

  def read_definition(path) do
    File.read!("#{@kraken_folder}/#{path}")
  end

  setup do
    Kraken.Services.define(read_definition("services/greeter.json"))
    Kraken.Services.start("greeter")
    Kraken.Services.define(read_definition("services/kv-store.json"))
    Kraken.Services.start("kv-store")
    Kraken.Pipelines.define(read_definition("pipelines/hello.json"))
    Kraken.Pipelines.start("hello")
    Kraken.Routes.define(read_definition("routes.json"))

    on_exit(fn ->
      Kraken.Services.delete("greeter")
      Kraken.Services.delete("kv-store")
      Kraken.Pipelines.delete("hello")
    end)
  end

  test "calls the pipeline" do
    event = %{"type" => "hello", "name" => "Anton"}
    result = Kraken.call(event)
    assert result["message"] == "Hello, Anton!"

    result = Kraken.call(event)
    assert result["message"] == "I've already said hello to you, Anton."
  end
end
