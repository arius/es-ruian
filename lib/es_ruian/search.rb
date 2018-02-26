# -*- encoding : utf-8 -*-
module EsRuian

  class Search

    @model_name = "address-register-search"

    #http://ruian.ispa.cz/api/address-register-search/by-filter
    #EsRuian::Search.by_filter municipality: "Brno", street: "Rooseveltova"
    #(dostupné filtry municipality, municipality_code, street, street_code, part_of_municipality, part_of_municipality_code, region, region_code, house_number, orientation_number
    def self.by_filter(filter_param)
      method_name = "by-filter"
      response = Connector.post([@model_name, method_name], filter_param)
    end


    #EsRuian::Search.multiple_by_filter({"1" => {municipality: "Brno", street: "Rooseveltova"}, "2" => {municipality: "Holice", street: "Vysokomýtská", house_number: 289}, limit: 1})

    def self.multiple_by_filter(filter_param)
      method_name = "multiple-by-filter"
      response = Connector.post([@model_name, method_name], filter_param)
    end


    #http://ruian.ispa.cz/api/address-register-search/by-fulltext/Holice, Vysokomýtská 289
    def self.by_fulltext(filter_param, options = {})
      method_name = "by-fulltext"

      array_path = [@model_name, method_name, filter_param]
      array_path << options[:limit] if options[:limit]
      options.delete(:limit)

      response = Connector.get(array_path, options)
    end

    #EsRuian::Search.multiple_by_fulltext "Vysokomýtská 289, Holice", "Rooseveltova, Brno"
    def self.multiple_by_fulltext(*params)
      method_name = "multiple-by-fulltext"
      response = Connector.post([@model_name, method_name], params)
    end

    def self.by_polygon(data, options = {})
      method_name = "by-polygon"
      response = Connector.post([@model_name, method_name], data, options)
    end

    #http://ruian.ispa.cz/api/address-register-search/by-circle/50.2399336/16.5188739/1000
    def self.by_circle(latitude, longitude, radius)
      method_name = "by-circle"
      response = Connector.get([@model_name, method_name, latitude, longitude, radius]).clone
    end


  end

end
