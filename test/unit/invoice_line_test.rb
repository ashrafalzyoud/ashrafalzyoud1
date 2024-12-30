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

class InvoiceLineTest < ActiveSupport::TestCase
  include RedmineInvoices::TestHelper
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles

  RedmineInvoices::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_invoices).directory + '/test/fixtures/', [:invoices,
                                                                                                                             :invoice_lines])

  def setup
    RedmineInvoices::TestCase.prepare
  end

  def test_accepts_numbers_with_commas
    line = InvoiceLine.new(description: 'desc', price: '123,45', quantity: '1,2')
    assert line.valid?, 'Should be valid'
    assert_equal line.price, 123.45
    assert_equal line.quantity, 1.2
  end

  def test_should_not_accepts_empty_numbers
    line = InvoiceLine.new(description: 'desc', price: '123,45', quantity: '')
    assert !line.valid?, 'Should be valid'
  end

  def test_should_be_visible_for_inoice_user
    line = InvoiceLine.new(description: 'desc', price: '123,45', quantity: '', invoice_id: 1)

    User.current = User.find(1)
    assert line.visible?, 'Should be visible for current user with access to project'
    assert line.visible?(User.find(2)), 'Should be visible for user with access to project'
    assert !line.visible?(User.find(4)), 'Should NOT be visible for user without access to project'
  end
end
