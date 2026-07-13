require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "name is required" do
    task = Task.new(name: nil, category: categories(:personal))

    assert_not task.valid?
    assert task.errors.of_kind?(:name, :blank)
  end

  test "name cannot be only whitespace" do
    task = Task.new(name: "   ", category: categories(:personal))

    assert_not task.valid?
    assert task.errors.of_kind?(:name, :blank)
  end

  test "name is stripped before validation" do
    task = Task.new(name: "  Comprar focos  ", category: categories(:personal))

    assert task.valid?
    assert_equal "Comprar focos", task.name
  end

  test "category defaults to Personal" do
    task = Task.new(name: "Comprar focos")

    assert task.valid?
    assert_equal "Personal", task.category_name
  end

  test "due reminders repeat daily for open overdue tasks" do
    travel_to Time.zone.local(2026, 7, 13, 10, 0, 0) do
      task = Task.create!(
        name: "Pagar recibo",
        category: categories(:casa),
        reminder_at: 1.day.ago,
        notified_at: Time.current.yesterday.change(hour: 18)
      )

      assert_includes Task.due_reminders, task
      assert task.due_for_notification?
    end
  end

  test "due reminders skip tasks already notified today" do
    travel_to Time.zone.local(2026, 7, 13, 10, 0, 0) do
      task = Task.create!(
        name: "Pagar recibo",
        category: categories(:casa),
        reminder_at: 1.day.ago,
        notified_at: Time.current.change(hour: 9)
      )

      assert_not_includes Task.due_reminders, task
      assert_not task.due_for_notification?
      assert task.overdue?
    end
  end

  test "due reminders include open tasks with target date due today" do
    travel_to Time.zone.local(2026, 7, 13, 10, 0, 0) do
      task = Task.create!(
        name: "Terminar cotizacion",
        category: categories(:personal),
        desired_completion_date: Date.current
      )

      assert_includes Task.due_reminders, task
      assert task.overdue?
    end
  end

  test "due reminders ignore closed overdue tasks" do
    travel_to Time.zone.local(2026, 7, 13, 10, 0, 0) do
      task = Task.create!(
        name: "Tarea cerrada",
        category: categories(:personal),
        status: :cerrada,
        reminder_at: 1.day.ago
      )

      assert_not_includes Task.due_reminders, task
      assert_not task.overdue?
    end
  end
end
