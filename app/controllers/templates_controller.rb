class TemplatesController < ApplicationController
  before_action :require_admin

  def index
    @templates = Template.all
    @template = Template.new
  end

  def create
    @template = build_template

    return if handle_missing_title

    valid_questions = extract_valid_questions
    return if handle_missing_questions(valid_questions)

    @template.skip_questions_validation = true
    save_template_and_questions(valid_questions)
  rescue => e
    handle_save_error("Erro ao criar template: #{e.message}")
  end

  def edit
    @template = Template.find(params[:id])
  end

  def update
    @template = Template.find(params[:id])
    if @template.update(template_params)
      flash[:notice] = "Template atualizado com sucesso!"
      redirect_to templates_path
    else
      flash.now[:alert] = "Não foi possível atualizar o template."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template = Template.find(params[:id])
    if @template.formularios.exists?
      flash[:alert] = "Não é possível deletar este template pois ele já possui formulários de avaliações vinculados."
    else
      @template.destroy
      flash[:notice] = "Template excluído com sucesso!"
    end
    redirect_to templates_path
  end

  private

  def save_template_and_questions(valid_questions)
    ActiveRecord::Base.transaction do
      if @template.save
        create_questions(valid_questions)
        flash[:notice] = "Template criado com sucesso!"
        redirect_to templates_path
      else
        handle_save_error("Não foi possível salvar o template.")
      end
    end
  end

  def template_params
    params.require(:template).permit(:titulo, :descricao)
  end

  def build_template
    p = params[:template]
    Template.new(
      titulo: p[:titulo],
      perfil_alvo: p[:perfil_alvo],
      criador: current_user,
      descricao: p[:descricao] || "Template para avaliações de #{p[:perfil_alvo]}"
    )
  end

  def handle_missing_title
    if params[:template][:titulo].blank?
      @templates = Template.all
      flash.now[:alert] = "Nome do Template não pode ficar em branco"
      render :index, status: :unprocessable_entity
      true
    else
      false
    end
  end

  def extract_valid_questions
    return [] unless params[:template][:perguntas].present?
    params[:template][:perguntas].reject { |p_param| p_param[:texto].blank? }
  end

  def handle_missing_questions(valid_questions)
    if valid_questions.empty?
      @templates = Template.all
      flash.now[:alert] = "O template deve ter ao menos uma pergunta"
      render :index, status: :unprocessable_entity
      true
    else
      false
    end
  end

  def create_questions(valid_questions)
    valid_questions.each_with_index do |p_param, index|
      QuestaoTemplate.create!(
        template: @template,
        enunciado: p_param[:texto],
        tipo: p_param[:tipo],
        obrigatoria: true,
        ordem: index + 1
      )
    end
  end

  def handle_save_error(message)
    @templates = Template.all
    flash.now[:alert] = message
    render :index, status: :unprocessable_entity
  end

end
