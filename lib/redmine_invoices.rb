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

class InvoicesSettings

  MACRO_LIST = '{{month_name}}, {{month_short_name}},
  {{id}}, {{year}}, {{month}}, {{day}}, {{daily_id}}, {{monthly_id}}, {{yearly_id}}, {{monthly_project_id}}, {{yearly_project_id}}, {{project_id}}, {{project_identifier}}'

  # Returns the value of the setting named name
  def self.[](name, project_id)
    project_id = project_id.id if project_id.is_a?(Project)
    contacts_setting = ContactsSetting[name, project_id]
    contacts_setting.blank? ? Setting.plugin_redmine_contacts_invoices[name.to_s] : contacts_setting
  end

  def self.disable_taxes?(project_id = nil)
    contacts_setting = ContactsSetting["disable_taxes", project_id]
    contacts_setting.blank? ? ContactsSetting.disable_taxes? : contacts_setting.to_i > 0
  end

  def self.paypal_enabled?(project_id = nil)
    self['invoices_paypal_enabled', project_id]
  end

  def self.total_including_tax?
    Setting.plugin_redmine_contacts_invoices['invoices_total_including_tax'].to_i > 0
  end

  def self.discount_after_tax?
    Setting.plugin_redmine_contacts_invoices['invoices_discount_after_tax'].to_i > 0
  end

  def self.use_current_user_email?
    Setting.plugin_redmine_contacts_invoices['invoices_email_current_user'].to_i > 0
  end

  def self.use_from_address_email?
    Setting.plugin_redmine_contacts_invoices['invoices_email_from_address'].present?
  end

  def self.email_from_address
    if InvoicesSettings.use_current_user_email?
      User.current.logged? ? "#{User.current.name} <#{User.current.mail}>" : Setting.mail_from
    else
      InvoicesSettings.use_from_address_email? ? Setting.plugin_redmine_contacts_invoices['invoices_email_from_address'] : Setting.mail_from
    end
  end

  def self.email_subject_template
    Setting.plugin_redmine_contacts_invoices['invoices_email_subject']
  end

  def self.default_list_style
    Setting.plugin_redmine_contacts_invoices['invoices_excerpt_invoice_list'].to_i > 0 ? 'list_excerpt' : 'list'

  end

  def self.show_units?(_project_id = nil)
    Setting.plugin_redmine_contacts_invoices['show_units'].to_i > 0
  end

  def self.custom_template(project_id = nil)
    InvoicesSettings['invoices_custom_template', project_id]
  end

  def self.template(project_id = nil)
    InvoicesSettings['invoices_template', project_id]
  end

  def self.is_custom_template?(project_id = nil)
    InvoicesSettings.template(project_id) == RedmineInvoices::TEMPLATE_CUSTOM
  end

  def self.public_links?
    Setting.plugin_redmine_contacts_invoices['invoices_public_links'].to_i > 0
  end

  def self.products_plugin_installed?
    @@products_plugin_installed ||= (Redmine::Plugin.installed?(:redmine_products) && Gem::Version.new(Redmine::Plugin.find(:redmine_products).version) >= Gem::Version.new('1.0.3'))
  end

  def self.finance_plugin_installed?
    @@finance_plugin_installed ||= (Redmine::Plugin.installed?(:redmine_finance) && Gem::Version.new(Redmine::Plugin.find(:redmine_finance).version) >= Gem::Version.new('2.1.5'))
  end

  def self.per_invoice_templates?
    Setting.plugin_redmine_contacts_invoices['per_invoice_templates'].to_i > 0
  end
end

module RedmineInvoices
  TEMPLATE_CLASSIC = 'classic'
  TEMPLATE_MODERN = 'modern'
  TEMPLATE_CUSTOM = 'custom'

  def self.settings() Setting[:plugin_redmine_contacts_invoices].blank? ? {} : Setting[:plugin_redmine_contacts_invoices] end

  def self.invoice_lines_units
    settings[:invoices_units].blank? ? [] : settings[:invoices_units].split("\n")
  end

  def self.available_locales
    Dir.glob(File.join(Redmine::Plugin.find(:redmine_contacts_invoices).directory, 'config', 'locales', '*.yml')).collect { |f| File.basename(f).split('.').first }.collect(&:to_sym)
    # [:en, :de, :fr, :ru]
  end

  def self.default_user_rate(user, project)
    return 0.0 unless Redmine::Plugin.installed?(:redmine_budgets)

    UserRate.bill_rate_for(user, user.today, project) || UserRate.bill_rate_for(user, user.today) || 0.0
  end
  def self.build_zip(reports)
    Zip::OutputStream.write_buffer do |zos|
      reports.each do |report|
        zos.put_next_entry report.filename
        zos.write report.content
      end
    end.string
  end

  module Hooks
    class ViewLayoutsBaseHook < Redmine::Hook::ViewListener
      render_on :view_layouts_base_html_head, :inline => "<%= stylesheet_link_tag :invoices, :plugin => 'redmine_contacts_invoices' %>"
    end
  end
end

class String
  def to_class
    Kernel.const_get self
  rescue NameError
    nil
  end

  def is_a_defined_class?
    true if self.to_class
  rescue NameError
    false
  end
end

require_dependency 'zip'

REDMINE_CONTACTS_INVOICES_REQUIRED_FILES = [
  'redmine_invoices/reports/invoice_reports',
  'redmine_invoices/hooks/views_layouts_hook',
  'redmine_invoices/hooks/controller_contacts_duplicates_hook',
  'redmine_invoices/patches/queries_helper_patch',
  'redmine_invoices/patches/project_patch',
  'redmine_invoices/patches/contact_patch',
  'redmine_invoices/patches/add_helpers_for_invoices_patch',
  'redmine_invoices/patches/mailer_patch',
  'redmine_invoices/patches/notifiable_patch',
  'redmine_invoices/patches/activeview_base_patch',
  'redmine_invoices/patches/contacts_controller_patch',
  'redmine_invoices/invoice_formater',
  'redmine_invoices/liquid/invoices',
  'redmine_invoices/patches/query_patch',
  'redmine_invoices/hooks/views_context_menus_hook',
  'redmine_invoices/hooks/views_contacts_hook',
  'redmine_invoices/patches/application_helper_patch',
  'redmine_invoices/patches/projects_helper_patch',
  'redmine_invoices/patches/contacts_helper_patch',
  'redmine_invoices/hooks/views_custom_fields_hook',
  'redmine_invoices/patches/custom_fields_helper_patch',
  'redmine_invoices/patches/field_format_patch',
  'redmine_invoices/wiki_macros/invoices_wiki_macros',
  'redmine_invoices/field_format/invoice_format',
  'redmine_invoices/field_format/expense_format',
]

REDMINE_CONTACTS_INVOICES_REQUIRED_FILES << 'redmine_invoices/patches/operation_patch' if InvoicesSettings.finance_plugin_installed?

base_url = File.dirname(__FILE__)
REDMINE_CONTACTS_INVOICES_REQUIRED_FILES.each { |file| require(base_url + '/' + file) }
