# -*- encoding : utf-8 -*-
module EsRuian

  class AddressPlace
    @model_name = "addresses"

    # http://ruian.ispa.cz/api/addresses/by_code/34711
    # EsRuian::AddressPlace.by_code(34711)
    def self.by_code(code)
      method_name = "by_code"
      response = Connector.get([@model_name, method_name, code])
    end


    # http://ruian.ispa.cz/api/addresses/by-codes
    # EsRuian::AddressPlace.by_codes(34711, 34746, 34789, 34797, 34801)
    def self.by_codes(*codes)
      method_name = "by_codes"
      response = Connector.post([@model_name, method_name], { codes: codes })
    end

    # http://ruian.ispa.cz/api/addresses/by_municipality/530395
    # EsRuian::AddressPlace.by_municipality(530395)
    def self.by_municipality(code)
      method_name = "by_municipality"
      response = Connector.get([@model_name, method_name, code])
    end

    # http://ruian.ispa.cz/api/addresses/by_street/768979
    # EsRuian::AddressPlace.by_street(768979)
    def self.by_street(code)
      method_name = "by_street"
      response = Connector.get([@model_name, method_name, code])
    end

    # http://ruian.ispa.cz/api/addresses/by_district/3407
    # EsRuian::AddressPlace.by_district(3407)
    def self.by_district(code)
      method_name = "by_district"
      response = Connector.get([@model_name, method_name, code])
    end

    # http://ruian.ispa.cz/api/addresses/by_province/34
    # EsRuian::AddressPlace.by_region(34)
    def self.by_region(code)
      method_name = "by_province"
      response = Connector.get([@model_name, method_name, code])
    end

    # http://ruian.ispa.cz/api/addresses/by_municipality_part/138851
    # EsRuian::AddressPlace.by_partOfMunicipality(138851)
    def self.by_partOfMunicipality(code)
      method_name = "by_municipality_part"
      response = Connector.get([@model_name, method_name, code])
    end
  end
end
