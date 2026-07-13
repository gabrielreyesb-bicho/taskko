require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "name is required" do
    category = Category.new(name: " ")

    assert_not category.valid?
    assert category.errors.of_kind?(:name, :blank)
  end

  test "name is stripped before validation" do
    category = Category.new(name: "  Finanzas  ")

    assert category.valid?
    assert_equal "Finanzas", category.name
  end
end
