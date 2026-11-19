class CalculationsController < ApplicationController
  before_action :load_areas

  def new
    @form = CalculationForm.with_defaults
  end

  def create
    @form = CalculationForm.new(form_params)
    render :new, status: @form.calculate ? :ok : :unprocessable_entity
  end

  private

  def load_areas
    @areas = HpiIndexRepository.default.areas
  end

  def form_params
    params.require(:calculation_form).permit(:price, :borough, :from_date, :to_date)
  end
end
