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

class ImportsControllerTest < ActionController::TestCase
  include RedmineContacts::TestHelper

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  RedmineInvoices::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/', [:contacts,
                                                                                                                    :contacts_projects,
                                                                                                                    :deals,
                                                                                                                    :notes,
                                                                                                                    :tags,
                                                                                                                    :taggings])

  RedmineInvoices::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_invoices).directory + '/test/fixtures/', [:invoices,
                                                                                                                             :invoice_lines])

  def setup
    RedmineInvoices::TestCase.prepare

    User.current = nil
    @request.session[:user_id] = 1
    @expense_csv_file = Rack::Test::UploadedFile.new(fixture_files_path + 'expenses_correct.csv', 'text/comma-separated-values')
    @invoice_csv_file = Rack::Test::UploadedFile.new(fixture_files_path + 'invoices_correct.csv', 'text/comma-separated-values')
    @separator = Redmine::VERSION.to_s > '4.2.2' ? ',' : ';'
  end

  def teardown
    Import.destroy_all
  end

  # Expense Import Tests

  def test_should_open_expense_import_form
    compatible_request :get, :new, type: 'ExpenseImport', project_id: 1
    assert_response :success
    assert_select 'form input#file'
  end

  def test_should_create_new_expense_import_object
    compatible_request :get, :create, type: 'ExpenseImport', project_id: 1, file: @expense_csv_file
    assert_response :redirect
    assert_equal Import.last.class, ExpenseImport
    assert_equal Import.last.user, User.find(1)
    assert_equal Import.last.project.id, 1

    import_settings = Import.last.settings
    project_id = import_settings['mapping']['project_id']
    wrapper, date_format = import_settings['wrapper'], import_settings['date_format']
    expected_settings = { 'project_id' => project_id, 'wrapper' => wrapper, 'date_format' => date_format }
    assert_equal expected_settings, { 'project_id' => 1, 'wrapper' => "\"", 'date_format' => '%m/%d/%Y' }
    assert %w[; ,].include?(Import.last.settings['separator'])
    assert %w[ISO-8859-1 UTF-8].include?(Import.last.settings['encoding'])
  end

  def test_should_open_expense_import_settings_page
    import = ExpenseImport.new
    import.user = User.find(1)
    import.settings['mapping'] = { 'project_id' => 1 }
    import.file = @expense_csv_file
    import.save!
    compatible_request :get, :settings, id: import.filename
    assert_response :success
    assert_select 'form#import-form'
  end

  def test_should_show_expense_import_mapping_page
    import = ExpenseImport.new
    import.user = User.find(1)
    import.settings = { 'mapping' => {'project_id' => 1},
                        'separator' => ';',
                        'wrapper' => "\"",
                        'encoding' => 'UTF-8',
                        'date_format' => '%m/%d/%Y' }
    import.file = @expense_csv_file
    import.save!
    compatible_request :get, :mapping, id: import.filename
    assert_response :success
    assert_select "select[name='import_settings[mapping][expense_date]']"
    assert_select "select[name='import_settings[mapping][status]']"
    assert_select 'table.sample-data tr'
    assert_select 'table.sample-data tr td', 'Описание затраты'
    assert_select 'table.sample-data tr td', 'marat@mail.ru'
  end

  def test_should_successfully_expense_import_from_csv_with_new_import
    import = ExpenseImport.new
    import.user = User.find(1)
    import.settings = { 'separator' => ';',
                        'wrapper' => "\"",
                        'encoding' => 'UTF-8',
                        'date_format' => '%m/%d/%Y' }
    import.file = @expense_csv_file
    import.save!
    compatible_request :post, :mapping, id: import.filename, project_id: 1,
                        import_settings: { mapping: { project_id: 1, expense_date: 1, status: 6, description: 4, contact: 5 } }
    assert_response :redirect
    compatible_request :post, :run, id: import.filename, project_id: 1, format: :js
    expense = Expense.last
    assert_equal expense.expense_date, Date.parse('2012-12-17')
    assert_equal expense.description, 'Описание затраты'
    assert_equal expense.contact.name, Contact.where('email LIKE ?', 'marat@mail.ru%').first.name
  end

  # Invoice Import Tests

  test 'should open invoice import form' do
    compatible_request :get, :new, type: 'InvoiceImport', project_id: 1
    assert_response :success
    assert_select 'form input#file'
  end

  test 'should create new invoice import object' do
    compatible_request :get, :create, type: 'InvoiceImport', project_id: 1, file: @invoice_csv_file
    assert_response :redirect
    assert_equal Import.last.class, InvoiceImport
    assert_equal Import.last.user, User.find(1)
    assert_equal Import.last.project.id, 1

    import_settings = Import.last.settings
    project_id = import_settings['mapping']['project_id']
    wrapper, date_format = import_settings['wrapper'], import_settings['date_format']
    expected_settings = { 'project_id' => project_id, 'wrapper' => wrapper, 'date_format' => date_format }
    assert_equal expected_settings, { 'project_id' => 1, 'wrapper' => "\"", 'date_format' => '%m/%d/%Y' }
    assert %w[; ,].include?(Import.last.settings['separator'])
    assert %w[ISO-8859-1 UTF-8].include?(Import.last.settings['encoding'])
  end

  test 'should open invoice import settings page' do
    import = InvoiceImport.new
    import.user = User.find(1)
    import.settings['mapping'] = { 'project_id' => 1 }
    import.file = @invoice_csv_file
    import.save!
    compatible_request :get, :settings, id: import.filename
    assert_response :success
    assert_select 'form#import-form'
  end

  test 'should show invoice import mapping page' do
    import = InvoiceImport.new
    import.user = User.find(1)
    import.settings = { 'mapping' => {'project_id' => 1},
                        'separator' => ';',
                        'wrapper' => "\"",
                        'encoding' => 'UTF-8',
                        'date_format' => '%m/%d/%Y' }
    import.file = @invoice_csv_file
    import.save!
    compatible_request :get, :mapping, :id => import.filename
    assert_response :success
    assert_select "select[name='import_settings[mapping][number]']"
    assert_select "select[name='import_settings[mapping][status]']"
    assert_select 'table.sample-data tr'
    assert_select 'table.sample-data tr td', 'СЧЕТ-№11'
    assert_select 'table.sample-data tr td', 'marat@mail.ru'
  end

  test 'should successfully invoice import from CSV with new import' do
    import = InvoiceImport.new
    import.user = User.find(1)
    import.settings = { 'separator' => ';',
                        'wrapper' => "\"",
                        'encoding' => 'UTF-8',
                        'date_format' => '%Y-%m-%d' }
    import.file = @invoice_csv_file
    import.save!
    compatible_request :post, :mapping, id: import.filename, project_id: 1,
                        import_settings: { mapping: { project_id: 1, number: 0, invoice_date: 1, status: 7, contact: 3 } }
    assert_response :redirect
    compatible_request :post, :run, id: import.filename, project_id: 1, format: :js
    invoice = Invoice.last
    assert_equal invoice.number, 'СЧЕТ-№11'
    assert_equal invoice.status, 'Draft'
    assert_equal invoice.contact.name, Contact.where('email LIKE ?', 'marat@mail.ru%').first.name
  end
end if Redmine::VERSION.to_s >= '4.1'
