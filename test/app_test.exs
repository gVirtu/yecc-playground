defmodule AppTest do
  use ExUnit.Case
  doctest App

  describe "evaluate" do
    test "single statement with semicolon" do
      int = Enum.random(1..100)
      assert {:ok, int} == App.evaluate("#{int};")
    end

    test "single statement without semicolon" do
      int = Enum.random(1..100)
      assert {:ok, int} == App.evaluate("#{int}")
    end

    test "multi statement" do
      int_a = Enum.random(1..100)
      int_b = Enum.random(1..100)
      assert {:ok, int_b} == App.evaluate("#{int_a}; #{int_b};")
    end

    test "operation add" do
      int_a = Enum.random(1..100)
      int_b = Enum.random(1..100)
      assert {:ok, int_a + int_b} == App.evaluate("#{int_a} + #{int_b};")
    end

    test "operation add (concat strings)" do
      str_a = "foo"
      str_b = "bar"
      assert {:ok, str_a <> str_b} == App.evaluate(~s/"#{str_a}" + "#{str_b}";/)
    end

    test "operation sub" do
      int_a = Enum.random(1..100)
      int_b = Enum.random(1..100)
      assert {:ok, int_a - int_b} == App.evaluate("#{int_a} - #{int_b};")
    end

    test "operation mul" do
      int_a = Enum.random(1..100)
      int_b = Enum.random(1..100)
      assert {:ok, int_a * int_b} == App.evaluate("#{int_a} * #{int_b};")
    end

    test "operation div" do
      int_a = Enum.random(1..100)
      int_b = Enum.random(1..100)
      assert {:ok, int_a / int_b} == App.evaluate("#{int_a} / #{int_b};")
    end

    test "operator precedence" do
      int_a = Enum.random(1..100)
      int_b = Enum.random(1..100)
      int_c = Enum.random(1..100)
      assert {:ok, int_a + (int_b * int_c)} == App.evaluate("#{int_a} + #{int_b} * #{int_c};")
      assert {:ok, int_a - (int_b * int_c)} == App.evaluate("#{int_a} - #{int_b} * #{int_c};")
      assert {:ok, int_a + (int_b / int_c)} == App.evaluate("#{int_a} + #{int_b} / #{int_c};")
      assert {:ok, int_a - (int_b / int_c)} == App.evaluate("#{int_a} - #{int_b} / #{int_c};")
    end

    test "parenthesization" do
      int_a = Enum.random(1..100)
      int_b = Enum.random(1..100)
      int_c = Enum.random(1..100)
      assert {:ok, (int_a + int_b) * int_c} == App.evaluate("(#{int_a} + #{int_b}) * #{int_c};")
      assert {:ok, (int_a - int_b) * int_c} == App.evaluate("(#{int_a} - #{int_b}) * #{int_c};")
      assert {:ok, (int_a + int_b) / int_c} == App.evaluate("(#{int_a} + #{int_b}) / #{int_c};")
      assert {:ok, (int_a - int_b) / int_c} == App.evaluate("(#{int_a} - #{int_b}) / #{int_c};")
    end

    test "assignment" do
      name = "foo"
      int_a = Enum.random(1..100)

      assert {:ok, int_a} == App.evaluate("#{name} = #{int_a}; #{name};")
    end

    test "error (parser) - empty program" do
      assert {:error, {_line, :parser, _error}} = App.evaluate("")
    end

    test "error (lexer) - invalid token" do
      assert {:error, {_line, :lexer, _error}, _line_number} = App.evaluate("â")
    end
  end
end
