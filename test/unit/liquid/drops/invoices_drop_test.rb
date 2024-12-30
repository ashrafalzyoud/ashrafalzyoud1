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

require File.expand_path('../../../liquid/liquid_test_helper', __FILE__)

class InvoicesDropTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :issues, :attachments
  RedmineInvoices::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_invoices).directory + '/test/fixtures/', [:invoices])

  def setup
    @invoice = Invoice.first
    @contact = @invoice.contact
    @assign = @invoice.assigned_to
    @liquid_render = LiquidRender.new('user' => Redmineup::Liquid::UserDrop.new(@contact),
                                      'invoice' => InvoiceDrop.new(@invoice),
                                      'invoices' => InvoicesDrop.new(Invoice.all))
  end

  def test_invoices_all
    invoices_descriptions = @liquid_render.render('{% for invoice in invoices.all %} {{invoice.description }} {% endfor %}')
    Invoice.all.map(&:description).each do |description|
      assert_match description, invoices_descriptions
    end
  end

  def test_invoice_contact
    assert_equal @contact.name, @liquid_render.render('{{ invoice.contact.name }}')
  end

  def test_invoice_assigned_to
    assert_equal @assign.name, @liquid_render.render('{{ invoice.assigned_to.name }}')
  end
  def test_invoice_attachments
    attachment = Attachment.first
    @invoice.attachments << attachment
    assert_equal @invoice.attachments.count.to_s, @liquid_render.render('{{ invoice.attachments.size }}')
    assert_equal @invoice.attachments.first.author.name, @liquid_render.render('{% assign attach = invoice.attachments | first %}{{ attach.author.name }}')
  end
end
