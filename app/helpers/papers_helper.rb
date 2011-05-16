module PapersHelper
  include Prawn::Measurements
  
  def layout_name_options
    Prawn::Document::PageGeometry::SIZES.map { |key, value|
      ["#{key.downcase.capitalize} (#{pt2mm(value.first).to_i}mm x #{pt2mm(value.last).to_i}mm)", key]
    }.sort
  end
end
