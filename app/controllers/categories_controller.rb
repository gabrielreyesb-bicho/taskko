class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @category = Category.new
    load_categories
  end

  def edit
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: "Categoría creada."
    else
      load_categories
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Categoría actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.tasks.exists?
      redirect_to categories_path, alert: "No se puede eliminar una categoría con tareas asociadas."
    else
      @category.destroy
      redirect_to categories_path, notice: "Categoría eliminada.", status: :see_other
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end

  def load_categories
    @categories = Category.ordered.to_a
    @task_counts = Task.group(:category_id).count
  end
end
