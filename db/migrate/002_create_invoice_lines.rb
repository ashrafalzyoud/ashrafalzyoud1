# This file is a part of Redmine Invoices (redmine_contacts_invoices) plugin,
# invoicing plugin for Redmine
#
# Copyright (C) 2011-2024 RedmineUP
# https://www.redmineup.com/
#
# redmine_contacts_invoices is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts_invoices is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts_invoices.  If not, see <http://www.gnu.org/licenses/>.

class CreateInvoiceLines < ActiveRecord::Migration[4.2]
  def self.up
    create_table :invoice_lines do |t|
      t.integer  :invoice_id
      t.integer  :position
      t.decimal  :quantity, :precision => 10, :scale => 2, :default => 1, :null => false
      t.string   :description, :limit => 512
      t.decimal  :tax, :precision => 20, :scale => 2
      t.decimal  :price, :precision => 20, :scale => 2, :default => 0, :null => false
      t.string   :units
      t.timestamps :null => false
    end
    add_index :invoice_lines, :invoice_id
  end

  def self.down
    drop_table :invoice_lines
  end
end
