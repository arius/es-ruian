# -*- encoding : utf-8 -*-
module EsRuian
  class Autocomplete
    # @model_name = "address-register-autocomplete"
    @model_name = "search"

    # http://ruian.eurosignal.cz/api/search/municipality_parts/Hol
    # EsRuian::Autocomplete.municipalities_with_parts_by_filter('Hol')
    def self.municipalities_with_parts_by_filter(filter_param)
      method_name = "municipality_parts"
      response = Connector.get([@model_name, method_name, filter_param])
    end

    # http://ruian.eurosignal.cz/api/search/districts/Pardub
    # EsRuian::Autocomplete.districts_by_filter('Pard')
    def self.districts_by_filter(filter_param)
      method_name = "districts"
      response = Connector.get([@model_name, method_name, filter_param])
    end

    # http://ruian.eurosignal.cz/api/search/streets_by_municipality/535419/Adiny%20Mandlové
    # EsRuian::Autocomplete.streets_by_filter(535419, 'Adiny')
    def self.streets_by_filter(city_code, filter_param)
      method_name = "streets_by_municipality"
      response = Connector.get([@model_name, method_name, city_code, filter_param])
    end

    # http://ruian.eurosignal.cz/api/search/streets_by_municipality_part/96610/HRUBINOVA
    # EsRuian::Autocomplete.streets_by_part_of_city_filter(96610, 'HRUBINOVA')
    def self.streets_by_part_of_city_filter(part_of_city_code, filter_param)
      method_name = "streets_by_municipality_part"
      response = Connector.get([@model_name, method_name, part_of_city_code, filter_param])
    end

    # http://ruian.eurosignal.cz/api/addresses/by_street/370410
    def self.house_numbers_by_street_code(street_code, filter_param)
      model_name = "addresses"
      method_name = "by_street"
      response = Connector.get([model_name, method_name, street_code, filter_param])
    end

    # http://ruian.eurosignal.cz/api/search/addresses_without_street_by_municipality_code/574988
    def self.house_numbers_without_street_by_city_code(city_code, filter_param)
      method_name = "addresses_without_street_by_municipality_code"
      response = Connector.get([@model_name, method_name, city_code, filter_param])
    end

    # http://ruian.eurosignal.cz/api/search/addresses_without_street_by_municipality_part_code/410471
    def self.house_numbers_without_street_by_part_of_city_code(part_city_code)
      method_name = "addresses_without_street_by_municipality_part_code"
      response = Connector.get([@model_name, method_name, part_city_code])
    end
  end
end
