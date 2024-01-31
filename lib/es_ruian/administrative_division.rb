# -*- encoding : utf-8 -*-
module EsRuian
  class AdministrativeDivision
    @model_name = 'administrative_divisions'

    # http://ruian.eurosignal.cz/api/administrative_divisions/by_gps/49.9278992/14.3389639
    # EsRuian::AdministrativeDivision.by_gps(49.9278992, 14.3389639)
    def self.by_gps(latitude, longitude, options = {})
      method_name = 'by_gps'
      response = Connector.get([@model_name, method_name, latitude, longitude], options)
    end
    
    def self.by_name(name, options = {})
      method_name = 'by_name'
      response = Connector.get([@model_name, method_name, name], options)
    end
    
    def self.by_code(name, options = {})
      method_name = 'by_code'
      response = Connector.get([@model_name, method_name, name], options)
    end
    
  end
end
