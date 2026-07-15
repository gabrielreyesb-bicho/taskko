class TasksController < ApplicationController
  # La lista arranca en "Abiertas": es la vista de trabajo del día a día.
  DEFAULT_STATUS = "abierta".freeze
  # Una URL sin :status ya significa "abiertas", así que ver todas las tareas
  # requiere pedirlo de forma explícita.
  ALL_STATUSES = "todas".freeze
  # "Hoy" y "Vencidas" no son estatus sino vistas por fecha: viajan en el mismo
  # parámetro porque son excluyentes entre sí y con los estatus.
  DATE_VIEWS = { "hoy" => :due_today, "vencidas" => :overdue_tasks }.freeze

  before_action :set_task, only: %i[show edit update destroy update_status]
  before_action :set_categories, only: %i[index new edit create update]

  def index
    @all_statuses = ALL_STATUSES
    @status_param = normalized_status(params[:status])
    @category_filter = params[:category_id].presence
    @tasks = scope_for(@status_param)
    @tasks = @tasks.where(category_id: @category_filter) if @category_filter.present?

    # Activas primero, luego por prioridad (alta arriba) y recordatorio más próximo.
    @tasks = @tasks.includes(:category).order(
      Arel.sql("CASE WHEN status IN (2, 3) THEN 1 ELSE 0 END"),
      priority: :desc,
      reminder_at: :asc,
      created_at: :desc
    )
  end

  def show
  end

  def new
    @task = Task.new(category: default_category)
  end

  def edit
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to tasks_path, notice: "Tarea creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: "Tarea actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Tarea eliminada.", status: :see_other
  end

  # Cambio rápido de estatus desde la lista.
  def update_status
    if Task.statuses.key?(params[:value]) && @task.update(status: params[:value])
      redirect_to tasks_path, notice: "Estatus actualizado."
    else
      redirect_to tasks_path, alert: "No se pudo actualizar el estatus."
    end
  end

  private

  # Un valor desconocido (una URL vieja con ?status=en_proceso, por ejemplo)
  # cae al default en vez de mostrar todo, que sería justo lo contrario.
  def normalized_status(value)
    value = value.presence
    return DEFAULT_STATUS if value.nil?
    return value if value == ALL_STATUSES || DATE_VIEWS.key?(value) || Task.statuses.key?(value)

    DEFAULT_STATUS
  end

  def scope_for(value)
    return Task.all if value == ALL_STATUSES
    return Task.public_send(DATE_VIEWS.fetch(value)) if DATE_VIEWS.key?(value)

    Task.where(status: value)
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :name, :notes, :category_id, :assigned_to, :priority, :status,
      :desired_completion_date, :reminder_at
    )
  end

  def set_categories
    @categories = Category.ordered
  end

  def default_category
    Category.find_by("lower(name) = ?", "personal") || Category.ordered.first
  end
end
