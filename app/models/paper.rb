# Template for a paper with practice squares.
class Paper < ActiveRecord::Base
  include Prawn::Measurements
  
  # User-friendly template name.
  validates :name, :length => 1..64, :presence => true, :uniqueness => true
  
  # Paper width, in PDF units.
  validates :layout_width, :numericality => { :greater_than => 0 },
                           :presence => true
  # Paper height, in PDF units.
  validates :layout_height, :numericality => { :greater_than => 0 },
                           :presence => true
  # User-friendly name for the paper dimensions (e.g. A4).
  validates :layout_name, :length => 1..16, :presence => true
  
  # Space left at the top of the paper, in cm.
  validates :margin_top, :numericality => { :greater_than_or_equal_to => 0 },
                         :presence => true
  # Space left at the bottom of the paper, in cm.
  validates :margin_bottom, :numericality => { :greater_than_or_equal_to => 0 },
                            :presence => true
  # Space left at the left of the paper, in cm.
  validates :margin_left, :numericality => { :greater_than_or_equal_to => 0 },
                          :presence => true
  # Space left at the right of the paper, in cm.
  validates :margin_right, :numericality => { :greater_than_or_equal_to => 0 },
                           :presence => true

  # The size of a square character cell, in cm.
  validates :cell_size, :numericality => { :greater_than_or_equal_to => 0 },
                         :presence => true
  # The space between two groups of rows cells, in cm.
  validates :group_spacing, :numericality => { :greater_than_or_equal_to => 0 },
                            :presence => true
  # The number of rows in a group.
  validates :group_rows, :presence => true, :numericality =>
      { :greater_than => 0, :only_integer => true }

  # Number of horizontal guide lines in a cell.
  validates :horizontal_guides, :presence => true, :numericality =>
      { :greater_than_or_equal_to => 0, :only_integer => true }
  # Number of vertical guide lines in a cell.
  validates :vertical_guides, :presence => true, :numericality =>
      { :greater_than_or_equal_to => 0, :only_integer => true }
  # Whether cells have diagonal guide lines making up a cross-hatch.
  validates :diagonal_guides, :inclusion => { :in => [true, false] }
  
  # Width of the cell border lines, in mm.
  validates :cell_stroke_size, :numericality => { :greater_than => 0 },
                               :presence => true
  # Width of the guide lines inside cells, in mm.
  validates :guide_stroke_size, :numericality => { :greater_than => 0 },
                                :presence => true

  # Color of the cell border lines, formated as rrggbb hex digits.
  validates :cell_stroke_color, :format => /^[0-9a-f]{6}$/,
                                :presence => true

  # Color of the guide lines inside cells, formated as rrggbb hex digits.
  validates :guide_stroke_color, :format => /^[0-9a-f]{6}$/,
                                 :presence => true


  # :nodoc: auto-fills width and height
  def layout_name=(new_layout)
    super
    layout = Prawn::Document::PageGeometry::SIZES[new_layout]
    self.layout_width, self.layout_height = *layout
  end
  
  # PDF bits.
  def to_pdf
    pdf = Prawn::Document.new :page_size => [layout_width, layout_height],
                              :margin => 0
    pdf_grid pdf
    pdf.render
  end
  
  # Draws the grid on a PDF document.
  def pdf_grid(pdf)
    groups = self.grid_row_groups
  
    0.upto(groups - 1) do |group|
      0.upto(group_rows - 1) do |row|
        pdf_grid_row pdf, group_rows * (groups - group) - row,
            margin_bottom_pdf +
            (cell_size_pdf * group_rows + group_spacing_pdf) * group +
            cell_size_pdf * row
      end
    end
  end
  
  # Draws a grid row on a PDF document.
  def pdf_grid_row(pdf, row_number, y_bottom)
    columns = self.grid_columns
    
    left = margin_left_pdf
    right = left + cell_size_pdf * columns
    bottom = y_bottom
    top = bottom + cell_size_pdf
    
    # Guide lines.
    old_stroke_color = pdf.stroke_color
    pdf.stroke_color = guide_stroke_color
    pdf.line_width guide_stroke_size_pdf
    pdf.stroke do
      spacing = cell_size_pdf / (1 + horizontal_guides)
      1.upto(horizontal_guides) do |i|
        pdf.line left, bottom + i * spacing, right, bottom + i * spacing
      end
      
      0.upto(columns - 1) do |j|
        cell_left = left + cell_size_pdf * j
        1.upto(vertical_guides) do |i|
          pdf.line cell_left + i * spacing, top, cell_left + i * spacing, bottom
        end
        
        if diagonal_guides
          pdf.line cell_left, top, cell_left + cell_size_pdf, bottom
          pdf.line cell_left + cell_size_pdf, top, cell_left, bottom
        end
      end
    end

    # Cell borders.
    pdf.stroke_color = cell_stroke_color
    pdf.line_width cell_stroke_size_pdf
    pdf.stroke do
      pdf.rectangle [left, top], columns * cell_size_pdf, cell_size_pdf
      1.upto(columns - 1) do |i|
        pdf.line left + cell_size_pdf * i, top, left + cell_size_pdf * i, bottom
      end
    end
    pdf.stroke_color = old_stroke_color
  end
  
  # Number of grid row groups that will fit on a page.
  def grid_row_groups
    height = layout_height - margin_bottom_pdf - margin_top_pdf
    group_height = cell_size_pdf * group_rows
    
    1 + ((height - group_height) /
         (group_height + group_spacing_pdf).to_f).floor
  end
  
  # Number of grid rows that will fit on a page.
  def grid_rows
    grid_row_groups * group_rows
  end
    
  # Number of character squares in each row that will fit on a page.
  def grid_columns
    width = layout_width - margin_left_pdf - margin_right_pdf
    (width / cell_size_pdf.to_f).floor
  end

  # Handy methods for converting from cm to PDF-native units.
  [
    :margin_top, :margin_bottom, :margin_left, :margin_right,
    :cell_size, :group_spacing
  ].each do |size|
    define_method :"#{size}_pdf" do
      cm2pt self.send(size)
    end
  end
  [:cell_stroke_size, :guide_stroke_size].each do |size|
    define_method :"#{size}_pdf" do
      mm2pt self.send(size)
    end
  end
  
  def load_defaults
    self.layout_name = 'LETTER'
    self.margin_top = 2
    self.margin_bottom = 1
    self.margin_left = 2.5
    self.margin_right = 2
    
    self.cell_size = 1.2
    self.group_spacing = 1.32
    self.group_rows = 1
    
    self.horizontal_guides = 0
    self.vertical_guides = 0
    self.diagonal_guides = false
    
    self.cell_stroke_size = 0.5
    self.guide_stroke_size = 0.1
    self.cell_stroke_color = '000000'
    self.guide_stroke_color = '666666'
  end
end
