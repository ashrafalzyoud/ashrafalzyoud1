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

class InvoiceImport < Import
  AUTO_MAPPABLE_FIELDS = {
    'number' => 'field_number',
    'invoice_date' => 'field_invoice_date',
    'status' => 'field_status',
    'due_date' => 'field_due_date',
    'contact' => 'field_contact',
    'amount' => 'field_amount',
    'currency' => 'field_currency',
    'discount' => 'field_discount',
    'subject' => 'field_subject',
    'assigned_to' => 'field_assigned_to'
  }

  def self.authorized?(user)
    user.allowed_to?(:import_invoices, nil, :global => true)
  end

  def saved_objects
    object_ids = saved_items.pluck(:obj_id)
    Invoice.where(:id => object_ids).order(:id)
  end

  def project
    Project.find_by(id: settings['mapping']['project_id'])
  end

  def mappable_custom_fields
    InvoiceCustomField.all
  end

  def allowed_target_projects
    Project.allowed_to(user, :import_invoices)
  end

  private

  def build_object(row, _item = nil)
    invoice = Invoice.new
    invoice.project = project
    invoice.author = user

    attributes = {}
    if number = row_value(row, 'number')
      attributes['number'] = number
    end
    if invoice_date = row_date(row, 'invoice_date')
      attributes['invoice_date'] = invoice_date
    end
    if due_date = row_date(row, 'due_date')
      attributes['due_date'] = due_date
    end
    if contact = row_value(row, 'contact')
      attributes['contact_id'] = Contact.where("email LIKE ?", "#{contact.strip}%").first.try(:id)
    end
    if amount = row_value(row, 'amount')
      attributes['lines_attributes'] = { '0' => { 'description' => 'imported line', 'quantity' => '1', 'units' => '1', 'price' => amount } }
    end
    if currency = row_value(row, 'currency')
      attributes['currency'] = currency
    end
    if discount = row_value(row, 'discount')
      attributes['discount'] = discount.to_f
    end
    if status = row_value(row, 'status')
      attributes['status_id'] = status =~ /\A\d+\Z/ ? status : Invoice::STATUSES_STRINGS.key(status)
    end
    if subject = row_value(row, 'subject')
      attributes['subject'] = subject
    end
    if assigned_to = row_value(row, 'assigned_to')
      attributes['assigned_to_id'] = User.where("LOWER(CONCAT(#{User.table_name}.firstname,' ',#{User.table_name}.lastname)) = ? ", assigned_to.mb_chars.downcase.to_s)
                                         .first
                                         .try(:id)
    end

    attributes['custom_field_values'] = invoice.custom_field_values.inject({}) do |h, v|
      value = case v.custom_field.field_format
              when 'date'
                row_date(row, "cf_#{v.custom_field.id}")
              else
                row_value(row, "cf_#{v.custom_field.id}")
              end
      h[v.custom_field.id.to_s] = v.custom_field.value_from_keyword(value, invoice) if value
      h
    end

    invoice.send :safe_attributes=, attributes, user
    invoice
  end
end
