require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "la lista arranca mostrando solo las abiertas" do
    get tasks_path

    assert_response :success
    assert_match tasks(:abierta).name, response.body
    assert_no_match(/#{tasks(:cerrada).name}/, response.body)
  end

  test "ver todas las tareas requiere pedirlo explicitamente" do
    get tasks_path(status: TasksController::ALL_STATUSES)

    assert_response :success
    assert_match tasks(:abierta).name, response.body
    assert_match tasks(:cerrada).name, response.body
  end

  test "un estatus valido filtra por ese estatus" do
    get tasks_path(status: "cerrada")

    assert_response :success
    assert_match tasks(:cerrada).name, response.body
    assert_no_match(/#{tasks(:abierta).name}/, response.body)
  end

  # Una URL vieja con ?status=en_proceso no debe destapar las cerradas.
  test "un estatus desconocido cae al default" do
    get tasks_path(status: "en_proceso")

    assert_response :success
    assert_match tasks(:abierta).name, response.body
    assert_no_match(/#{tasks(:cerrada).name}/, response.body)
  end

  test "el filtro de categoria conserva el estatus elegido" do
    get tasks_path(status: TasksController::ALL_STATUSES, category_id: categories(:casa).id)

    assert_response :success
    assert_match tasks(:cerrada).name, response.body
    assert_no_match(/#{tasks(:abierta).name}/, response.body)
  end

  test "en proceso ya no es un estatus valido" do
    assert_not Task.statuses.key?("en_proceso")
  end

  test "la vista Hoy muestra solo lo que vence hoy" do
    de_hoy = crear(desired_completion_date: Date.current)
    de_manana = crear(desired_completion_date: Date.current + 1)

    get tasks_path(status: "hoy")

    assert_response :success
    assert_match de_hoy.name, response.body
    assert_no_match(/#{de_manana.name}/, response.body)
  end

  test "la vista Vencidas muestra solo lo que ya se paso" do
    vencida = crear(desired_completion_date: Date.current - 1)
    de_hoy = crear(desired_completion_date: Date.current)

    get tasks_path(status: "vencidas")

    assert_response :success
    assert_match vencida.name, response.body
    assert_no_match(/#{de_hoy.name}/, response.body)
  end

  test "las vistas por fecha se combinan con el filtro de categoria" do
    de_casa = crear(desired_completion_date: Date.current, category: categories(:casa), name: "Meta de hoy en casa")
    personal = crear(desired_completion_date: Date.current, name: "Meta de hoy personal")

    get tasks_path(status: "hoy", category_id: categories(:casa).id)

    assert_response :success
    assert_match de_casa.name, response.body
    assert_no_match(/#{personal.name}/, response.body)
  end

  # Las vistas de detalle y formulario no tenían cobertura: un helper borrado
  # las tumbaba sin que ningún test se enterara.
  test "el detalle de una tarea abre" do
    get task_path(crear(desired_completion_date: Date.current - 1, reminder_at: 2.days.ago))
    assert_response :success

    get task_path(crear)
    assert_response :success
  end

  test "los formularios de alta y edicion abren" do
    get new_task_path
    assert_response :success

    get edit_task_path(tasks(:abierta))
    assert_response :success
  end

  private

  def crear(**attrs)
    attrs[:name] ||= "Tarea generada #{attrs.hash.abs}"
    attrs[:category] ||= categories(:personal)
    Task.create!(**attrs)
  end
end
