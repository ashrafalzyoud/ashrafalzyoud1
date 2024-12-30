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

module ExpensesHelper

  def expense_status_tag(expense)
    content_tag(:span, expense_status_name(expense.status_id), :class => "status-badge expense-status #{expense_status_name(expense.status_id, true).to_s}")
  end

  def expense_status_name(status, code=false)
    return (code ? "draft" : l(:label_expense_status_draft)) unless collection_expense_statuses.map{|v| v[1]}.include?(status)

    status_data = collection_expense_statuses.select{|s| s[1] == status }.first[0]
    status_name = collection_expense_status_names.select{|s| s[1] == status}.first[0]
    return (code ? status_name : status_data)
  end

  def collection_expense_status_names
    [[:draft, Expense::DRAFT_EXPENSE],
     [:new, Expense::NEW_EXPENSE],
     [:billed, Expense::BILLED_EXPENSE],
     [:paid, Expense::PAID_EXPENSE]]
  end

  def expense_status_url(status_id, options={})
    {:controller => 'expenses',
     :action => 'index',
     :set_filter => 1,
     :project_id => @project,
     :fields => [:status_id],
     :values => {:status_id => [status_id]},
     :operators => {:status_id => '='}}.merge(options)
  end

  def collection_expense_statuses
    [[l(:label_expense_status_draft), Expense::DRAFT_EXPENSE],
     [l(:label_expense_status_new), Expense::NEW_EXPENSE],
     [l(:label_expense_status_billed), Expense::BILLED_EXPENSE],
     [l(:label_expense_status_paid), Expense::PAID_EXPENSE]]
  end

  def collection_for_expense_status_for_select(status_id)
    collection = collection_expense_statuses.map{|s| [s[0], s[1].to_s]}
    collection.insert 0, [l(:label_open_issues), "o"]
    collection.insert 0, [l(:label_all), ""]

    options_for_select(collection, status_id)

  end

  def expenses_is_no_filters
    (params[:status_id] == 'o' && (params[:period].blank? || params[:period] == 'all') && params[:contact_id].blank? && params[:is_billable].blank?)
  end

  def expenses_to_csv(expenses, query, options={})
    columns = query.columns
    price_index = columns.index { |c| c.name == :price }
    columns.insert(price_index + 1, QueryColumn.new(:currency)) if price_index

    Redmine::Export::CSV.generate(encoding: params[:encoding], field_separator: params[:field_separator]) do |csv|
      # csv header fields
      csv << columns.map {|c| c.caption.to_s}
      # csv lines
      expenses.each do |expense|
        csv << columns.map { |c| (c.name == :contact && expense.contact_id) ? expense.contact.primary_email : csv_content(c, expense) }
      end
    end
  end

  def importer_link
    project_expense_imports_path
  end

  def importer_show_link(importer, project)
    project_expense_import_path(:id => importer, :project_id => project)
  end

  def importer_settings_link(importer, project)
    settings_project_expense_import_path(:id => importer, :project => project)
  end

  def importer_run_link(importer, project)
    run_project_expense_import_path(:id => importer, :project_id => project, :format => 'js')
  end

  def importer_link_to_object(expense)
    link_to expense.description, edit_expense_path(expense)
  end

  def _project_expenses_path(project, *args)
    if project
      project_expenses_path(project, *args)
    else
      expenses_path(*args)
    end
  end
  def select2_expense_tag(name, expenses, options = {})
    expenses = [expenses] unless expenses.is_a?(Array)

    s = select2_tag(
      name,
      options_for_select(expenses.map{ |c| [c.try(:to_s), c.try(:id)] }, expenses.map{ |c| c.try(:id) }),
      url: auto_complete_expenses_path(project_id: @project.try(:id)),
      placeholder: '',
      multiple: !!options[:multiple],
      containerCssClass: options[:class] || 'icon icon-expense',
      style: 'width: 60%;',
      include_blank: true,
      allow_clear: !!options[:include_blank]
    )
    s.html_safe
  end

  def link_to_expense(expense)
    link_to expense.to_s, edit_expense_path(expense),
      class: "issue icon icon-expense#{' closed' unless expense.is_open?}",
      title: "#{expense.description unless expense.description.blank? }"
  end
end
