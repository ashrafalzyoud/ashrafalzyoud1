# encoding: utf-8
#
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

require File.expand_path('../../test_helper', __FILE__)  

class ExpenseImportTest < ActiveSupport::TestCase
  fixtures :projects

  def test_open_correct_csv
    assert_difference('Expense.count', 1, 'Should have 1 expense in the database') do
      expense_import = generate_import_with_mapping
      assert expense_import.run, 1
    end
  end

  protected

  def generate_import(fixture_name='expenses_correct.csv')
    import = ExpenseImport.new
    import.user_id = 2
    import.file = Rack::Test::UploadedFile.new(fixture_files_path + fixture_name, 'text/csv')
    import.save!
    import
  end

  def generate_import_with_mapping(fixture_name='expenses_correct.csv')
    import = generate_import(fixture_name)

    import.settings = {
      'separator' => ';',
      'wrapper' => '"',
      'encoding' => 'UTF-8',
      'date_format' => '%m/%d/%Y',
      'mapping' => {'project_id' => '1', 'expense_date' => '1', 'status' => '6', 'description' => '4'}
    }
    import.save!
    import
  end
end if Redmine::VERSION.to_s >= '4.1'
