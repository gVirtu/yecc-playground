defmodule AppTest do
  use ExUnit.Case
  doctest App

  describe "evaluate" do
    test "empty program" do
      assert {:ok, nil} == App.evaluate("")
    end

    test "literals" do
      int = Enum.random(1..100)
      string = "string with escaped \"quotes\",\nmultiple lines and a backslash: \\"
      bool = true
      list = [1, 2, "three"]
      map = %{"x" => 100, "y" => [2, 0, 0], "z" => "300"}
      map_string = "{x: 100, y: [2, 0, 0], z: \"300\"}"

      assert {:ok, nil} == App.evaluate("nil")
      assert {:ok, int} == App.evaluate("#{inspect int}")
      assert {:ok, string} == App.evaluate("#{inspect string}")
      assert {:ok, bool} == App.evaluate("#{inspect bool}")
      assert {:ok, list} == App.evaluate("#{inspect list}")
      assert {:ok, map} == App.evaluate("#{map_string}")
    end

    test "multi statement" do
      program = """
      a = 0
      a = a + 1

      a = a + 1; a = a + 1;
      a = a +
          1
      """
      assert {:ok, 4} == App.evaluate(program)
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

    test "unary operators" do
      int_a = Enum.random(1..100)
      assert {:ok, -int_a} == App.evaluate("-#{int_a};")
      assert {:ok, +int_a} == App.evaluate("+#{int_a};")
      assert {:ok, true} == App.evaluate("!false;")
      assert {:ok, false} == App.evaluate("not true;")
    end

    test "arithmetic operator precedence" do
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

    test "numeric comparison" do
      int_a = Enum.random(1..100)
      int_b = Enum.random(1..100)
      assert {:ok, (int_a > int_b)} == App.evaluate("#{int_a} > #{int_b};")
      assert {:ok, (int_a < int_b)} == App.evaluate("#{int_a} < #{int_b};")
      assert {:ok, (int_a >= int_b)} == App.evaluate("#{int_a} >= #{int_b};")
      assert {:ok, (int_a <= int_b)} == App.evaluate("#{int_a} <= #{int_b};")
      assert {:ok, (int_a != int_b)} == App.evaluate("#{int_a} != #{int_b};")
      assert {:ok, (int_a == int_b)} == App.evaluate("#{int_a} == #{int_b};")
    end

    test "boolean expressions" do
      assert {:ok, true} == App.evaluate("true or false")
      assert {:ok, false} == App.evaluate("true and false")
      assert {:ok, true} == App.evaluate("true || false")
      assert {:ok, false} == App.evaluate("true && false")
      assert {:ok, true} == App.evaluate("!false")
      assert {:ok, false} == App.evaluate("not true")
    end

    test "assignment" do
      name = "foo"
      int_a = Enum.random(1..100)

      assert {:ok, int_a} == App.evaluate("#{name} = #{int_a}; #{name};")
    end

    test "accessors" do
      list = [10, 20, 30, 40]
      assert {:ok, 20} == App.evaluate("L = #{inspect list}; L[1]")
      assert {:ok, 40} == App.evaluate("L = #{inspect list}; L[-1]")
      assert {:ok, nil} == App.evaluate("L = #{inspect list}; L[999]")

      map_string = "{x: \"foo\", y: \"bar\", \"key with spaces\": \"baz\"}"
      assert {:ok, "bar"} == App.evaluate("M = #{map_string}; M[\"y\"]")
      assert {:ok, "baz"} == App.evaluate("M = #{map_string}; M[\"key with spaces\"]")
      assert {:ok, nil} == App.evaluate("M = #{map_string}; M[0]")

      nested = """
      N = [0, ["a", nil, {x: {y: "hello world!"}}], 2]
      N[1, 2, "x", "y"]
      """

      assert {:ok, "hello world!"} == App.evaluate(nested)
    end

    test "line breaks" do
      assert {:ok, 1} == App.evaluate("\na = \n1; \na")
      assert {:ok, 2} == App.evaluate("(\n1 +\n 1\n)")
      assert {:ok, [3]} == App.evaluate("[\n3\n]")
      assert {:ok, %{"x" => 4}} == App.evaluate("{\nx :\n4\n}")
      assert {:ok, 5} == App.evaluate("10 -\n 5\n")
      assert {:ok, 6} == App.evaluate("3 *\n 2\n")
      assert {:ok, 7} == App.evaluate("49 /\n 7\n")
      assert {:ok, 8} == App.evaluate("+\n 8\n")
      assert {:ok, 9} == App.evaluate("-\n (-9)\n")
      assert {:ok, true} == App.evaluate("false or\n true\n")
      assert {:ok, false} == App.evaluate("true and\n false\n")
      assert {:ok, true} == App.evaluate("not\n false\n")
      assert {:ok, false} == App.evaluate("1 >\n 2\n")
      assert {:ok, true} == App.evaluate("1 <\n 2\n")
      assert {:ok, false} == App.evaluate("1 >=\n 2\n")
      assert {:ok, true} == App.evaluate("1 <=\n 2\n")
      assert {:ok, false} == App.evaluate("1 ==\n 2\n")
      assert {:ok, true} == App.evaluate("1 !=\n 2\n")
      assert {:ok, "ok"} == App.evaluate("substring (\n\"It's ok\",\n5,\n2\n)\n")
    end

    test "error (parser) - stray semicolon" do
      assert {:error, {_line, :parser, _error}} = App.evaluate(";")
    end

    test "error (lexer) - invalid token" do
      assert {:error, {_line, :lexer, _error}, _line_number} = App.evaluate("â")
    end
  end
end
