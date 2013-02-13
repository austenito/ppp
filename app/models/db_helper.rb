class DbHelper
  def self.rollback(models)
    for model in models
      model.destroy
    end
  end
end