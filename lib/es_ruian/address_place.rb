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

    # http://ruian.ispa.cz/api/search/by_circle/50.2399336/16.5188739/1000?kind=address
    # EsRuian::AddressPlace.by_circle(48.9955900658021, 16.7245099565193, 0.1)
    def self.by_circle(latitude, longitude, radius, options = {})
      method_name = 'by_circle'
      options[:kind] = 'address'
      response = Connector.get(['search', method_name, latitude, longitude, radius], options)
    end

    # http://ruian.ispa.cz/api/search/by_polygon
    # EsRuian::AddressPlace.by_polygon(49.83673269054116, 14.878281170088316, 49.837077845263984, 14.877046036780422, 49.83628715293106, 14.877263743487353)
    def self.by_polygon(*data)
      method_name = 'by_polygon'
      response = Connector.post(['search', method_name], { points: data, kind: 'address' })
    end
  end
end
