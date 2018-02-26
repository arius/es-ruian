# -*- encoding : utf-8 -*-
module EsRuian

  class AddressPlace
    @model_name = "addresses"
    @model_type = "address_place"

    # curl -X GET -H "Content-Type: application/vnd.api+json" http://ruian.ispa.cz/api/addresses/by_municipality/565709 -v
    # curl -X GET -H "Content-Type: application/vnd.api+json" http://ruian.ispa.cz/api/addresses/by_municipality_part/50784 -v
    # curl -X GET -H "Content-Type: application/vnd.api+json" http://ruian.ispa.cz/api/addresses/by_street/292796 -v
    # curl -X GET -H "Content-Type: application/vnd.api+json" http://ruian.ispa.cz/api/addresses/by_district/3811 -v


    #http://ruian.ispa.cz/api/addresses/by_code/9695711
    def self.by_code(code)
      method_name = "by_code"
      response = Connector.get([@model_name, method_name, code])
    end

    #http://ruian.ispa.cz/api/addresses/by-codes
    def self.by_codes(*codes)
      p codes
      method_name = "by_codes"
      response = Connector.post([@model_name, method_name], { codes: codes }, type: @model_type)
    end

    #http://ruian.ispa.cz/api/addresses/by_municipality/565709
    def self.by_municipality(code)
      method_name = "by_municipality"
      response = Connector.get([@model_name, method_name, code])
    end

    #http://ruian.ispa.cz/api/addresses/by_street/292796
    def self.by_street(code)
      method_name = "by_street"
      response = Connector.get([@model_name, method_name, code])
    end

    #http://ruian.ispa.cz/api/addresses/by_district/3811
    def self.by_district(code)
      method_name = "by_district"
      response = Connector.get([@model_name, method_name, code])
    end

    #http://ruian.ispa.cz/api/addresses/by_province/32
    def self.by_region(code)
      method_name = "by_province"
      response = Connector.get([@model_name, method_name, code])
    end

    #http://ruian.ispa.cz/api/addresses/by_municipality_part/50784
    def self.by_partOfMunicipality(code)
      method_name = "by_municipality_part"
      response = Connector.get(@model_name, method_name, code)
    end
  end
end
