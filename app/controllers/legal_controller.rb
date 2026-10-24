class LegalController < PublicController
  before_action :set_document

  layout 'legal'

  def privacy
    render :show
  end

  def terms
    render :show
  end

  private

  def set_document
    @legal = I18n.t('legal_pages', locale: :en)
    @document = @legal.fetch(action_name.to_sym)
  end
end
