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
      assert task.alert_fired?
      # Vence hoy, así que todavía no está vencida: TARS insiste, la lista no la pinta de rojo.
      assert_not task.overdue?
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

  # --- Vistas por fecha (Hoy / Vencidas) ---
  #
  # La regla: manda la meta. La alerta solo decide cuando no hay meta.

  test "la meta de hoy cae en Hoy" do
    task = crear(desired_completion_date: Date.current)

    assert_includes Task.due_today, task
    assert_not_includes Task.overdue_tasks, task
  end

  test "la meta pasada cae en Vencidas" do
    task = crear(desired_completion_date: Date.current - 1)

    assert_includes Task.overdue_tasks, task
    assert_not_includes Task.due_today, task
  end

  # El caso que importa: TARS empuja antes de tiempo, y eso no vence nada.
  test "una alerta que ya sono no vence una tarea cuya meta sigue en el futuro" do
    task = crear(desired_completion_date: Date.current + 1, reminder_at: 1.day.ago)

    assert_not_includes Task.overdue_tasks, task
    assert_not_includes Task.due_today, task
  end

  test "sin meta manda la alerta" do
    de_hoy = crear(reminder_at: Time.current.change(hour: 7))
    de_ayer = crear(reminder_at: 1.day.ago)
    de_manana = crear(reminder_at: 1.day.from_now)

    assert_includes Task.due_today, de_hoy
    assert_includes Task.overdue_tasks, de_ayer
    assert_not_includes Task.due_today, de_manana
    assert_not_includes Task.overdue_tasks, de_manana
  end

  test "una tarea sin fechas no aparece en ninguna vista" do
    task = crear

    assert_not_includes Task.due_today, task
    assert_not_includes Task.overdue_tasks, task
  end

  test "las vistas por fecha ignoran las tareas cerradas" do
    task = crear(desired_completion_date: Date.current - 1, status: :cerrada)

    assert_not_includes Task.overdue_tasks, task
    assert_not_includes Task.due_today, task
  end

  test "Hoy y Vencidas nunca comparten una tarea" do
    crear(desired_completion_date: Date.current)
    crear(desired_completion_date: Date.current - 1)
    crear(reminder_at: 1.day.ago)
    crear(desired_completion_date: Date.current + 1, reminder_at: 1.day.ago)

    assert_empty Task.due_today.ids & Task.overdue_tasks.ids
  end

  private

  def crear(**attrs)
    Task.create!(name: "Tarea de prueba", category: categories(:personal), **attrs)
  end
end
