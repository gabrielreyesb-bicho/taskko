class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy update_status]

  def index
    @status_filter = params[:status].presence
    @tasks = Task.all
    @tasks = @tasks.where(status: @status_filter) if @status_filter && Task.statuses.key?(@status_filter)

    # Activas primero, luego por prioridad (alta arriba) y recordatorio más próximo.
    @tasks = @tasks.order(
      Arel.sql("CASE WHEN status IN (2, 3) THEN 1 ELSE 0 END"),
      priority: :desc,
      reminder_at: :asc,
      created_at: :desc
    )
  end

  def show
  end

  def new
    @task = Task.new
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

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :description, :notes, :category, :assigned_to, :priority, :status,
      :desired_completion_date, :reminder_at
    )
  end
end
