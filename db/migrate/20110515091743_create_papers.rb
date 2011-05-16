class CreatePapers < ActiveRecord::Migration
  def self.up
    create_table :papers do |t|
      t.string :name, :length => 64, :null => false
      
      t.string :layout_name, :length => 16, :null => false
      t.float :layout_width, :null => false
      t.float :layout_height, :null => false
      
      t.float :margin_top, :null => false
      t.float :margin_bottom, :null => false
      t.float :margin_left, :null => false
      t.float :margin_right, :null => false

      t.float :cell_size, :null => false
      t.float :row_spacing, :null => false
      
      t.integer :horizontal_guides, :null => false
      t.integer :vertical_guides, :null => false
      t.boolean :diagonal_guides, :null => false
      
      t.float :cell_stroke_size, :null => false
      t.float :guide_stroke_size, :null => false

      t.timestamps
    end
    add_index :papers, :name, :unique => true, :null => false
  end

  def self.down
    drop_table :papers
  end
end
