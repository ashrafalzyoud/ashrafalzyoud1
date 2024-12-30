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

class ExtendScalesForInvoiceLines < ActiveRecord::Migration[5.0]
  def up
    change_column :invoice_lines, :tax, :decimal, precision: 20, scale: 4
    change_column :invoice_lines, :price, :decimal, precision: 20, scale: 4, default: 0, null: false
  end

  def down
    change_column :invoice_lines, :tax, :decimal, precision: 20, scale: 2
    change_column :invoice_lines, :price, :decimal, precision: 20, scale: 2, default: 0, null: false
  end
end
