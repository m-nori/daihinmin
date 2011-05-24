class DaihinminConst
  @@config = YAML.load_file(File.expand_path('../../config/daihinmin.yml',  __FILE__))

  def self.get(key)
    @@config[key]
  end
end
