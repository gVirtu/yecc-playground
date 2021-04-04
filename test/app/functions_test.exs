defmodule App.FunctionsTest do
  use ExUnit.Case
  doctest App.Functions

  describe "to_string" do
    test "converts integers" do
      int = Enum.random(1..100)
      assert {:ok, to_string(int)} == App.evaluate("to_string(#{int})")
    end

    test "noop with strings" do
      str = "foo"
      assert {:ok, str} == App.evaluate("to_string(\"#{str}\")")
    end
  end

  describe "substring" do
    test "with beginning" do
      str = "The quick brown fox jumps over the lazy dog."
      beginning = Enum.random(0..String.length(str))
      assert {:ok, String.slice(str, beginning, :infinity)} ==
        App.evaluate("substring(\"#{str}\", #{beginning})")
    end

    test "with beginning and count" do
      str = "The quick brown fox jumps over the lazy dog."
      count = Enum.random(0..div(String.length(str), 2))
      beginning = Enum.random(0..String.length(str)-count)
      assert {:ok, String.slice(str, beginning, count)} ==
        App.evaluate("substring(\"#{str}\", #{beginning}, #{count})")
    end
  end
end
