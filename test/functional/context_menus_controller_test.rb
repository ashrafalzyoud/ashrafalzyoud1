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

class ContextMenusControllerTest < ActionController::TestCase
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

  RedmineInvoices::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_invoices).directory + '/test/fixtures/', [:invoices,
                                                                                                                             :invoice_lines])

  def setup
    @project = Project.find(1)
    @project.enable_module! :contacts_invoices
    @request.session[:user_id] = 1
  end

  # tests include the same type of actions for the context menu for issues and time entries

  def test_should_get_invoice_on_single
    @request.session[:user_id] = 1

    check_for_issues({projects: @project.id, ids: ['1']}, 1)
    check_for_time_entries({projects: @project.id, ids: ['1']}, 1)
  end

  def test_should_get_without_invoice
    @project.disable_module! :contacts_invoices if @project.module_enabled?(:contacts_invoices)
    @request.session[:user_id] = 1

    check_for_issues({projects: @project.id, ids: ['1']}, 0)
    check_for_time_entries({projects: @project.id, ids: ['1']}, 0)
  end

  def test_should_get_with_invoice_on_multiple
    @request.session[:user_id] = 1

    check_for_issues({projects: @project.id, ids: ['1', '2']}, 1)
    check_for_time_entries({projects: @project.id, ids: ['1', '2']}, 1)
  end

  def test_should_get_without_invoice_on_multiple_if_module_disabled
    project2 = Project.find(2)
    project2.disable_module! :contacts_invoices if project2.module_enabled?(:contacts_invoices)
    project3 = Project.find(3)
    project3.disable_module! :contacts_invoices if project3.module_enabled?(:contacts_invoices)
    @request.session[:user_id] = 1

    check_for_issues({projects: [@project.id, project2.id], ids: ['1', '4']}, 0)
    check_for_time_entries({projects: [@project.id, project3.id], ids: ['1', '4']}, 0)
  end

  def test_should_get_with_invoice_on_multiple_if_modules_enabled
    project2 = Project.find(2)
    project2.enable_module! :contacts_invoices unless project2.module_enabled?(:contacts_invoices)
    project3 = Project.find(3)
    project3.enable_module! :contacts_invoices unless project3.module_enabled?(:contacts_invoices)
    @request.session[:user_id] = 1

    check_for_issues({projects: [@project.id, project2.id], ids: ['1', '4']}, 1)
    check_for_time_entries({projects: [@project.id, project3.id], ids: ['1', '4']}, 1)
  end

  private

  def check_for_issues(options = {}, count = 0)
    compatible_request :get, :issues, project_id: options[:projects], project_ids: options[:projects], ids: options[:ids]
    assert_response :success
    assert_select('a.icon-invoice-add-context', :count => count, text: 'Invoice')
  end

  def check_for_time_entries(options = {}, count = 0)
    compatible_request :get, :time_entries, project_id: options[:projects], project_ids: options[:projects], ids: options[:ids]
    assert_response :success
    assert_select('a.icon-invoice-add-context', :count => count, text: 'Invoice')
  end
end
