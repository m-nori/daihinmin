Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = SessionsController
end

class Warden::SessionSerializer
  def serialize(record)
    [record.class, record.id]
  end

  def deserialize(keys)
    klass, id = keys
    klass.find(:first, :conditions => { :id => id })
  end
end

Warden::Strategies.add(:password) do
  def valid?
    params.has_key?(:password) && params.has_key?(:name)
  end

  def authenticate!
    u = User.authenticate(params[:name],params[:password])
    u.nil? ? fail("Could not login") : success!(u)
  end
end

