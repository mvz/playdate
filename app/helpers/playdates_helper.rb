# frozen_string_literal: true

module PlaydatesHelper
  def daytype_options(selected)
    options_for_select({ 'Vrijdag'  => PlaydatesController::DAY_FRIDAY,
                         'Zaterdag' => PlaydatesController::DAY_SATURDAY },
                       selected)
  end

  def period_options(selected)
    options_for_select({ 'Deze maand'     => PlaydatesController::PERIOD_THIS_MONTH,
                         'Volgende maand' => PlaydatesController::PERIOD_NEXT_MONTH },
                       selected)
  end
end
