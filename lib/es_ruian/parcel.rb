# -*- encoding : utf-8 -*-
module EsRuian
  class Parcel
    @model_name = 'parcels'

    # http://ruian.ispa.cz/api/parcels/by_code/107611508
    # EsRuian::Parcel.by_code(107611508)
    def self.by_code(code, options = {})
      method_name = 'by_code'
      response = Connector.get([@model_name, method_name, code], options)
    end

    # http://ruian.ispa.cz/api/search/by_circle/50.2399336/16.5188739/1000?kind=parcel
    # EsRuian::Parcel.by_circle(48.9955900658021, 16.7245099565193, 0.1)
    def self.by_circle(latitude, longitude, radius, options = {})
      method_name = 'by_circle'
      options[:kind] = 'parcel'
      response = Connector.get(['search', method_name, latitude, longitude, radius], options)
    end

    # http://ruian.ispa.cz/api/search/by_polygon
    # EsRuian::Parcel.by_polygon(49.83673269054116, 14.878281170088316, 49.837077845263984, 14.877046036780422, 49.83628715293106, 14.877263743487353)
    def self.by_polygon(*data)
      method_name = 'by_polygon'
      response = Connector.post(['search', method_name], { points: data, kind: 'parcel' })
    end

    # http://ruian.ispa.cz/api/parcels/by_cadastral_area_and_parcel_number/600083/1
    # EsRuian::Parcel.by_cadastral_area_and_parcel_number(600083, 1)
    def self.by_cadastral_area_and_parcel_number(cadastral_area_code, parcel_number, options = {})
      method_name = 'by_cadastral_zoning_and_parcel_number'
      response = Connector.get([@model_name, method_name, cadastral_area_code, parcel_number], options)
    end
  end
end
