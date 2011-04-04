class SearchForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :q

  def initialize(params)
    self.q = params[:q] if params
  end

  def persisted?
    false
  end
end
