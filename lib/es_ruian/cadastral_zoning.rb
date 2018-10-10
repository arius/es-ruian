# -*- encoding : utf-8 -*-
module EsRuian
  class CadastralZoning
    @model_name = 'cadastral_zonings'

    # http://ruian.eurosignal.cz/api/cadastral_zonings/by_gps/49.9278992/14.3389639
    # EsRuian::CadastralZoning.by_gps(49.9278992, 14.3389639)
    def self.by_gps(latitude, longitude, options = {})
      method_name = 'by_gps'
      response = Connector.get([@model_name, method_name, latitude, longitude], options)
    end
  end
end
