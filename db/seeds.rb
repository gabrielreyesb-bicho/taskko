# Datos de ejemplo para desarrollo. Idempotente: no duplica.
if Task.count.zero?
  Task.create!([
    {
      description: "Comprar tanque de buceo nuevo",
      notes: "El de aluminio ya tiene demasiadas horas. Revisar opciones de acero.",
      category: "DiveOps",
      assigned_to: :gabriel,
      priority: :media,
      status: :abierta,
      desired_completion_date: Date.current + 10.days,
      reminder_at: 2.days.from_now
    },
    {
      description: "Pagar predial de la casa",
      notes: "Antes de que venza el descuento.",
      category: "Casa",
      assigned_to: :gabriel,
      priority: :alta,
      status: :en_proceso,
      desired_completion_date: Date.current + 3.days,
      reminder_at: 1.hour.ago # vencido → aparece en /api/v1/reminders/due
    },
    {
      description: "Agendar cita con el dentista",
      category: "Personal",
      assigned_to: :lucy,
      priority: :baja,
      status: :abierta,
      reminder_at: 5.days.from_now
    },
    {
      description: "Renovar dominio de Kollektor",
      category: "Personal",
      assigned_to: :gabriel,
      priority: :media,
      status: :cerrada
    }
  ])
  puts "Seeded #{Task.count} tareas."
else
  puts "Ya hay #{Task.count} tareas; no se sembró nada."
end
