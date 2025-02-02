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
  module Patches
    module ContactPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          has_many :invoices, :dependent => :nullify
          has_many :expenses, :dependent => :nullify
        end
      end

      module InstanceMethods
        # Adds a rates tab to the user administration page
        def invoices_balance
          scope = invoices.visible
          scope = scope.visible
          scope = scope.where(["#{Invoice.table_name}.contact_id = ?", id])
          scope.sent_or_paid.group(:currency).sum("#{Invoice.table_name}.amount - #{Invoice.table_name}.balance")
        end
      end
    end
  end
end

unless Contact.included_modules.include?(RedmineInvoices::Patches::ContactPatch)
  Contact.send(:include, RedmineInvoices::Patches::ContactPatch)
end
