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

module RedmineInvoices
  module FieldFormat
    class ExpenseFormat < Redmine::FieldFormat::RecordList
      add 'expense'
      self.customized_class_names = nil
      self.multiple_supported = true

      def edit_tag(view, tag_id, tag_name, custom_value, options = {})
        invoices = Expense.where(id: custom_value.value).to_a unless custom_value.value.blank?
        view.select2_expense_tag(tag_name, invoices, options.merge(id: tag_id,
                                                                   class: "expense_cf #{custom_value.custom_field.multiple ? 'select2_multi_cf' : '' }",
                                                                   include_blank: !custom_value.custom_field.is_required,
                                                                   multiple: custom_value.custom_field.multiple))
      end

      def query_filter_options(custom_field, query)
        super.merge(type: name.to_sym)
      end

      def validate_custom_value(_custom_value)
        []
      end

      def set_custom_field_value(custom_field, custom_field_value, value)
        value = value.flatten.reject(&:blank?) if value.is_a?(Array)
        super(custom_field, custom_field_value, value)
      end
    end
  end
end
