class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env

  def self.update_attribute!(attribute, value)
    file = YAML.load_file self.source
    file[Rails.env][attribute] = value
    File.open(self.source, 'w'){ |f| f.write file.to_yaml }
  end

end
