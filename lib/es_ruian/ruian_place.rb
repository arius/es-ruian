# -*- encoding : utf-8 -*-
module EsRuian
  class RuianPlace < OpenStruct

    # def parse_gps
    #   (gpsPoint || gps_point).gsub("(", "").gsub(")", "").split(",")
    # end

    def gps
      gps
    end

    def latitude
      gps[0]
    end

    def longitude
      gps[1]
    end

    def ruian_code
      id
    end
  end
end
