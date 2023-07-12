defmodule KrakenInit.Kraken.Lambdas.Greeter do
  def greet(%{"name" => name}) do
    %{"message" => "Hello, #{name}!"}
  end

  def no_greet(%{"name" => name}) do
    %{"message" => "I've already said hello to you, #{name}."}
  end
end
