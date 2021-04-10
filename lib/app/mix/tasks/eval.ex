defmodule Mix.Tasks.Eval do
  use Mix.Task

  @shortdoc "Calls the App.evaluate/1 function with the contents of the file path."
  def run([]) do
    IO.puts("You must specify a file: `mix eval input_path`")
  end

  def run([path]) do
    path
    |> File.read!()
    |> App.evaluate()
    |> IO.inspect(label: "RESULT")
  end
end
