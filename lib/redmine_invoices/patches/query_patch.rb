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

require_dependency 'query'

module RedmineInvoices
  module Patches
    module QueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :initialize_values_for_select2_without_invoices, :initialize_values_for_select2
          alias_method :initialize_values_for_select2, :initialize_values_for_select2_with_invoices
        end
      end

      module InstanceMethods
        def add_available_filter_with_invoices(field, options)
          add_available_filter_without_invoices(field, options)
          values = filters[field].blank? ? [] : filters[field][:values]
          initialize_values_for_select2(field, values)
          @available_filters
        end

        def add_filter_with_invoices(field, operator, values = nil)
          add_filter_without_invoices(field, operator, values)
          return unless available_filters[field]
          initialize_values_for_select2(field, values)
          true
        end

        def initialize_values_for_select2_with_invoices(field, values)
          initialize_values_for_select2_without_invoices(field, values)
          case @available_filters[field][:type]
          when :invoice
            @available_filters[field][:values] = Invoice.visible.where(id: values).map { |r| [r.to_s, r.id.to_s] }
          when :expense
            @available_filters[field][:values] = Expense.visible.where(id: values).map { |r| [r.to_s, r.id.to_s] }
          end
        end
      end
    end
  end
end

unless Query.included_modules.include?(RedmineInvoices::Patches::QueryPatch)
  Query.send(:include, RedmineInvoices::Patches::QueryPatch)
end
