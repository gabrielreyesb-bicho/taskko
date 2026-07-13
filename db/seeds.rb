# Datos de ejemplo para desarrollo. Idempotente: no duplica.
categories = %w[Personal Casa DiveOps TARS].index_with do |name|
  Category.find_or_create_by_name!(name)
end

if Task.count.zero?
  Task.create!([
    {
      name: "Comprar tanque de buceo nuevo",
      notes: "El de aluminio ya tiene demasiadas horas. Revisar opciones de acero.",
      category: categories.fetch("DiveOps"),
      assigned_to: :gabriel,
      priority: :media,
      status: :abierta,
      desired_completion_date: Date.current + 10.days,
      reminder_at: 2.days.from_now
    },
    {
      name: "Pagar predial de la casa",
      notes: "Antes de que venza el descuento.",
      category: categories.fetch("Casa"),
      assigned_to: :gabriel,
      priority: :alta,
      status: :en_proceso,
      desired_completion_date: Date.current + 3.days,
      reminder_at: 1.hour.ago # vencido → aparece en /api/v1/reminders/due
    },
    {
      name: "Agendar cita con el dentista",
      category: categories.fetch("Personal"),
      assigned_to: :lucy,
      priority: :baja,
      status: :abierta,
      reminder_at: 5.days.from_now
    },
    {
      name: "Renovar dominio de Kollektor",
      category: categories.fetch("Personal"),
      assigned_to: :gabriel,
      priority: :media,
      status: :cerrada
    }
  ])
  puts "Seeded #{Task.count} tareas."
else
  puts "Ya hay #{Task.count} tareas; no se sembró nada."
end
