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

require File.expand_path('../../../test_helper', __FILE__)

class Redmine::ApiTest::InvoicePaymentsTest < Redmine::ApiTest::Base
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

  RedmineInvoices::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_invoices).directory + '/test/fixtures/', [:invoices, :invoice_lines, :invoice_payments])

  def setup
    RedmineInvoices::TestCase.prepare
    Setting.rest_api_enabled = '1'
  end

  def test_get_invoice_payments
    invoice = Invoice.find(1)
    compatible_api_request :get, "/invoices/#{invoice.id}/invoice_payments.json", {}, credentials('admin')

    assert_response :success
    assert_match 'application/json', @response.content_type
    response_json = ActiveSupport::JSON.decode(@response.body)
    assert_equal invoice.payments.size, response_json['invoice_payments'].size
  end

  def test_post_invoice_payment
    invoice = Invoice.find(1)
    parameters = {
      invoice_payment: {
        amount: 100.0,
        payment_date: Date.today,
        description: 'API payment'
      }
    }

    assert_difference('InvoicePayment.count') do
      compatible_api_request :post, "/invoices/#{invoice.id}/invoice_payments.json", parameters, credentials('admin')
    end

    payment = InvoicePayment.order('id DESC').first
    assert_equal 100.0, payment.amount
    assert_equal 'API payment', payment.description

    assert_response :created
    assert_match 'application/json', @response.content_type
    response_json = ActiveSupport::JSON.decode(@response.body)
    assert_equal payment.id, response_json['payment']['id']
  end

  def test_post_invalid_invoice_payment
    invoice = Invoice.find(1)
    parameters = {
      invoice_payment: {
        amount: "foo",
        payment_date: Date.today,
        description: 'API payment'
      }
    }

    assert_no_difference('InvoicePayment.count') do
      compatible_api_request :post, "/invoices/#{invoice.id}/invoice_payments.json", parameters, credentials('admin')
    end

    assert_response 422
    assert_match 'application/json', @response.content_type
    response_json = ActiveSupport::JSON.decode(@response.body)
    assert_equal 1, response_json['errors'].size
  end

  def test_post_invoice_payment_with_uploaded_file
    file_content = 'test_create_with_upload'
    token = json_upload(file_content, credentials('admin'))
    attachment = Attachment.find_by_token(token)
    invoice = Invoice.find(1)

    # create the payment with the upload's token
    assert_difference 'InvoicePayment.count' do
      post(
        "/invoices/#{invoice.id}/invoice_payments.json",
        params:
          {invoice_payment:
            {amount: 100, description: 'API payment with upload', payment_date: Date.today,
             :uploads => [{:token => token, :filename => 'test.txt',
                           :content_type => 'text/plain'}]}},
        :headers => credentials('admin'))
      assert_response :created
    end

    payment = InvoicePayment.order('id DESC').first
    assert_equal 100, payment.amount
    assert_equal 'API payment with upload', payment.description
    assert_equal attachment, payment.attachments.first
  end

  def test_delete_invoice_payment
    payment = InvoicePayment.find(1)

    assert_difference('InvoicePayment.count', -1) do
      compatible_api_request :delete, "/invoices/#{payment.invoice.id}/invoice_payments/#{payment.id}.json", {}, credentials('admin')
    end

    assert_response :ok
    assert_nil InvoicePayment.find_by_id(payment.id)
  end
end
