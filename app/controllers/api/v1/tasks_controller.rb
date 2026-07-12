module Api
  module V1
    class TasksController < Api::BaseController
      before_action :set_task, only: %i[show update destroy notified]

      # GET /api/v1/tasks
      # Filtros opcionales: ?status=abierta&assigned_to=gabriel&category=Personal
      def index
        tasks = Task.all
        tasks = tasks.where(status: params[:status]) if Task.statuses.key?(params[:status])
        tasks = tasks.where(assigned_to: params[:assigned_to]) if Task.assigned_tos.key?(params[:assigned_to])
        tasks = tasks.where(category: params[:category]) if params[:category].present?
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
      # TARS marca que ya avisó de este recordatorio (idempotente).
      def notified
        @task.mark_notified!
        render json: serialize(@task)
      end

      private

      def set_task
        @task = Task.find(params[:id])
      end

      def task_params
        params.require(:task).permit(
          :description, :notes, :category, :assigned_to, :priority, :status,
          :desired_completion_date, :reminder_at, :notified_at
        )
      end

      def serialize(task)
        TaskSerializer.call(task)
      end
    end
  end
end
