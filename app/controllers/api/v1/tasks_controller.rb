module Api
  module V1
    class TasksController < Api::BaseController
      before_action :set_task, only: %i[show update destroy notified]

      # GET /api/v1/tasks
      # Filtros opcionales: ?status=abierta&assigned_to=gabriel&category=Personal
      def index
        tasks = Task.includes(:category)
        tasks = tasks.where(status: params[:status]) if Task.statuses.key?(params[:status])
        tasks = tasks.where(assigned_to: params[:assigned_to]) if Task.assigned_tos.key?(params[:assigned_to])
        tasks = tasks.where(category_id: params[:category_id]) if params[:category_id].present?
        tasks = tasks.joins(:category).where("lower(categories.name) = ?", params[:category].to_s.strip.downcase) if params[:category].present?
        tasks = tasks.order(created_at: :desc)
        render json: tasks.map { |t| serialize(t) }
      end

      # GET /api/v1/tasks/:id
      def show
        render json: serialize(@task)
      end

      # POST /api/v1/tasks
      def create
        task = Task.create!(task_params)
        render json: serialize(task), status: :created
      end

      # PATCH/PUT /api/v1/tasks/:id
      def update
        @task.update!(task_params)
        render json: serialize(@task)
      end

      # DELETE /api/v1/tasks/:id
      def destroy
        @task.destroy
        head :no_content
      end

      # POST /api/v1/tasks/:id/notified
      # TARS marca cuándo avisó por última vez de esta tarea (idempotente).
      def notified
        @task.mark_notified!
        render json: serialize(@task)
      end

      private

      def set_task
        @task = Task.find(params[:id])
      end

      def task_params
        permitted = params.require(:task).permit(
          :name, :description, :notes, :category, :category_id, :assigned_to, :priority, :status,
          :desired_completion_date, :reminder_at, :notified_at
        )
        permitted[:name] ||= permitted.delete(:description)
        category_name = permitted.delete(:category)
        permitted[:category_id] = Category.find_or_create_by_name!(category_name).id if category_name.present? && permitted[:category_id].blank?
        permitted.except(:description)
      end

      def serialize(task)
        TaskSerializer.call(task)
      end
    end
  end
end
