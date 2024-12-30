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
  module Reports
    module InvoiceReports
      class InvoiceDefaultTemplate
        include Redmine::I18n
        def content
          raise NotImplementedError
        end

        private

        def style
          style = <<-CSS
  .invoice #items {
    width: 100%;
  }
  .invoice .left {
    float: left;
  }
  .invoice .right {
    float: right;
  }
  .invoice .clear {
    clear: both;
  }
  .invoice .section {
    overflow: hidden;
  }
  .invoice table {
    border-collapse: collapse;
    border-spacing: 0px;
  }
  .invoice #invoice-number-label,
  .invoice .title {
    border-bottom: 2px solid #cccccc;
    color: #777777;
    font-size: 16px !important;
    font-weight: normal;
    line-height: 30px;
    margin-bottom: 2px;
  }
  .invoice #invoice-number-label,
  .invoice #invoice-number-value {
    border-bottom: 2px solid #cccccc;
    font-size: 14px;
    font-weight: bold;
  }
  .invoice .highlighted {
    background: #eeeeee;
  }
  .invoice .right-align {
    text-align: right;
  }
  .invoice #logo-img {
    background-position: 0px 0px;
    background-repeat: no-repeat;
    width: 7cm;
  }
  .invoice #logo-img img {
    max-height: 3cm;
    max-width: 7cm;
  }
  .invoice #company-info {
    margin-top: -9px;
    width: 10cm;
  }
  .invoice #customer {
    padding-top: 45px;
    width: 7cm;
  }
  .invoice #customer.title {
    overflow: hidden;
  }
  .invoice #customer > div {
    float: left;
    width: 50%;
  }
  .invoice #bill-to {
    width: 7cm;
  }
  .invoice #bill-to span {
    float: left;
  }
  .invoice #single-settings {
    padding-top: 45px;
    width: 10cm;
  }
  .invoice #single-settings > table {
    width: 100%;
    white-space: nowrap;
  }
  .invoice #single-settings > table .value {
    line-height: 30px;
    width: 50%;
  }
  .invoice #single-settings > table .label {
    color: #777777;
    font-size: 14px;
    padding-right: 10px;
  }
  .invoice #single-settings #invoice-number-label {
    font-weight: normal;
  }
  .invoice #invoice-title {
    color: #777777;
    font-size: 34px;
    line-height: 100%;
    padding-top: 30px;
    text-align: center;
    width: 100%;
  }
  .invoice #items {
    width: 100%;
  }
  .invoice #items > table {
    margin-top: 20px;
    width: 100%;
  }
  .invoice #items > table td {
    border-bottom: 1px solid #e1e0de;
    hyphens: auto;
    moz-hyphens: auto;
    ms-word-break: break-all;
    padding: 8px 15px 8px 0px;
    vertical-align: top;
    webkit-hyphens: auto;
    word-break: break-all;
    word-break: break-word;
  }
  .invoice #items > table th {
    border-bottom: 2px solid #cccccc;
    padding: 8px 15px 8px 0px;
    color: #777777;
    font-size: 14px;
    white-space: nowrap;
  }
  .invoice #items > table .position {
    min-width: 0.5cm;
    width: auto;
  }
  .invoice #items > table .description {
    width: auto;
  }
  .invoice #items > table .quantity {
    max-width: 2cm;
    text-align: right;
    white-space: nowrap;
    width: auto;
  }
  .invoice #items > table .price-unit {
    max-width: 2.5cm;
    ms-text-overflow: ellipsis;
    o-text-overflow: ellipsis;
    overflow: hidden;
    text-align: right;
    text-overflow: ellipsis;
    white-space: nowrap;
    width: auto;
  }
  .invoice #items > table .price {
    max-width: 2.5cm;
    padding-right: 0px;
    text-align: right;
    white-space: nowrap;
    width: auto;
  }
  .invoice #totals {
    font-size: 14px;
    max-width: 12cm;
    min-width: 7.35cm;
    padding-top: 30px;
  }
  .invoice #totals > table {
    width: 100%;
  }
  .invoice #totals > table .value {
    line-height: 26px;
    padding-right: 3px;
    vertical-align: middle;
  }
  .invoice #totals .label {
    color: #777777;
    padding-left: 11px;
    white-space: nowrap;
  }
  .invoice #totals .label > span {
    float: left;
  }
  .invoice #totals #total {
    color: black;
    font-size: 16px;
    font-weight: bold;
  }
  .invoice #totals #tax-text {
    margin-right: 5px;
  }
  .invoice #totals #tax2-text {
    margin-right: 5px;
  }
  .invoice #outstanding-balance > td {
    padding-top: 10px;
  }
  .invoice #expense {
    clear: both;
  }
  .invoice #footer {
    padding-top: 35px;
    width: 100%;
  }          
          CSS
          style
        end
      end

      class ClassicTemplate < InvoiceDefaultTemplate
        def content
          content = <<-HTML

  <style>
    #info {margin-bottom: 100px}
    #single-settings .date_row .label {white-space:nowrap;font-weight: bold;padding-right:10px}
    #single-settings td {vertical-align: top;}
    table#items-table { border-collapse: collapse;}
    table#items-table td, table#items-table th { border: 1px solid; padding: 3px;}
    thead#items-header th { white-space: nowrap;}
    tbody#items-body td.nw { white-space: nowrap; text-align: right;}
    tbody#items-body td.totals { border: 0px solid; text-align: right; font-weight: bold;white-space: nowrap;}
    tbody#items-body td.totals.label { padding-right: 20px;}
  </style>

  <div id="info">
    <div id="single-settings" style="float: right;width: 40%">
      <table>
        <tr class="date_row">
          <td class="label">#{l(:field_invoice_number)}:</td>
          <td class="value">{{invoice.number}}</td>
        </tr>
        {% if invoice.order_number != blank %}
        <tr class="date_row">
          <td class="label">#{l(:field_invoice_order_number)}:</td>
          <td class="value">{{ invoice.order_number}}</td>
        </tr>
        {% endif %}
        <tr class="date_row">
          <td class="label">#{l(:field_invoice_date)}:</td>
          <td class="value">{{ invoice.invoice_date | date: "%B %e, %Y"}}</td>
        </tr>
        {% if invoice.due_date != blank %}
        <tr>
          <td class="label">#{l(:field_invoice_due_date)}:</td>
          <td class="value">{{ invoice.due_date | date: "%B %e, %Y"}}</td>
        </tr>
        {% endif %}
        <tr class="date_row">
          <td class="label">#{l(:label_invoice_bill_to)}:</td>
          <td class="value">
            {% if invoice.contact.company != blank %}
            <b>{{ invoice.contact.company }}</b><br>
            {% endif %}
            {{ invoice.contact.name }}<br>
            {{ invoice.contact.address.post_address | multi_line }}
          </td>
        </tr>
      </table>
    </div>
    <div id="company-info" style="width: 40%">
      <h2>{{ account.company }}</h2>
      {{ account.representative }}<br>
      {{ account.info | multi_line }}<br>
    </div>
  </div>

  <h1 style="text-align:center">
    {% if invoice.is_estimate? %}
      #{l(:label_invoice_status_estimate)}
    {% else %}
      #{l(:label_invoice)}
    {% endif %}
  </h1>
  <table id="items-table" width="100%" >
    <thead id="items-header">
      <tr>
        <th class="item">#{l(:field_invoice_line_position)}</th>
        <th class="description">#{l(:field_invoice_line_description)}</th>
        <th class="quantity">#{l(:field_invoice_line_quantity)}</th>
        <th class="price-unit">#{l(:field_invoice_line_price)}</th>
        <th class="price">#{l(:field_invoice_line_total)}</th>
      </tr>
    </thead>
    <tbody id="items-body">
      {% for item in invoice.lines %}
      <tr class="item-row" id="row_{{ item.id}}">
        <td class="position">{{ item.position }}</td>
        <td class="description">{{ item.description | multi_line }}</td>
        <td class="quantity nw">x{{ item.quantity | numeric: 4 }}</td>
        <td class="price-unit nw">{{ item.price | currency }}</td>
        <td class="price nw">{{ item.total | currency }}</td>
      </tr>
      {% endfor %}
      <tr>
        <td class="totals label" colspan="4">#{l(:label_invoice_sub_amount)}:</td>
        <td class="totals">{{ invoice.subtotal | currency }}</td>
      </tr>

      {% if invoice.discount > 0 %}
      <tr>
        <td class="totals label" colspan="4">
          #{l(:field_invoice_discount)}
          {% if invoice.discount_type == 0 %}
            ({{invoice.discount_rate | round: 2 }}%)
          {% endif %}
        </td>
        <td class="totals">-{{ invoice.discount | round: 2 | currency }}</td>
      </tr>
      {% endif %}

      {% if invoice.has_taxes? %}
      {% for tax_group in invoice.tax_groups %}
      <tr>
        <td class="totals label" colspan="4">
          <span id="tax-text">#{l(:label_invoice_tax)}</span>
          <span id="tax-percent-value">{{tax_group[0] | round: 2 }}%</span>
        </td>
        <td class="totals">{{tax_group[1] | currency}}</td>
      </tr>
      {% endfor %}
      {% endif %}
      <tr>
        <td class="totals label" colspan="4">#{l(:label_invoice_amount_due)}:</td>
        <td class="totals">{{ invoice.amount | currency }}</td>
      </tr>
    </tbody>
  </table>
  <div class="section">
    <div id="payment_details">
       <div id="customer" class="title"></div>
       {{account.bill_info | textile | multi_line}}
    </div>
    <div id="footer" class="clear">
      {{ invoice.description | textile }}
    </div>
  </div>

HTML

          content
        end
      end
      class ModernTemplate < InvoiceDefaultTemplate
        def content
          content = <<-HTML

<div class="invoice">
  <div id="invoice-status" class="{{invoice.status}}"></div>
  <div id="logo-img" class="left">
    <img src="{{ account.logo }}">
  </div>
  <div id="company-info" class="right">
    <div class="title">#{l(:label_invoice_company_info)}</div>
    {{ account.company }}<br>
    {{ account.representative }}<br>
    {{ account.info | multi_line }}<br>
  </div>
  <div id="single-settings" class="right clear">
    <table>
      <thead>
        <tr>
          <th id="invoice-number-label" class="label">#{l(:field_invoice_number)}</th>
          <th id="invoice-number-value" class="value">{{ invoice.number }}</th>
        </tr>
      </thead>
      <tbody>
        {% if invoice.order_number != blank %}
        <tr class="date_row">
          <td class="label">#{l(:field_invoice_order_number)}:</td>
          <td class="value">{{ invoice.order_number}}</td>
        </tr>
        {% endif %}        
        <tr id="date-row">
          <td id="date-label" class="label">#{l(:field_invoice_date)}</td>
          <td id="date-value" class="value">{{ invoice.invoice_date | date: "%B %e, %Y"}}</td>
        </tr>
        {% if invoice.due_date != blank %}
        <tr>
          <td id="due-date-label" class="label">#{l(:field_invoice_due_date)}</td>
          <td id="due-date-value">{{ invoice.due_date | date: "%B %e, %Y"}}</td>
        </tr>
        {% endif %}
      </tbody>
    </table>
  </div>
  <div class="left">
    <div id="customer" class="title">#{l(:label_invoice_bill_to)}</div>
    <div id="bill-to">
      {{ invoice.contact.company }}<br>
      {{ invoice.contact.name }}<br>
      {{ invoice.contact.address.post_address | multi_line }}
    </div>
  </div>
  <div id="invoice-title" class="clear">
    {% if invoice.is_estimate? %}
      #{l(:label_invoice_status_estimate)}
    {% else %}
      #{l(:label_invoice)}
    {% endif %}
  </div>
  <div id="items">
    <table id="items-table">
      <thead id="items-header">
        <tr>
          <th class="item">#{l(:field_invoice_line_position)}</th>
          <th class="description">#{l(:field_invoice_line_description)}</th>
          <th class="quantity">#{l(:field_invoice_line_quantity)}</th>
          <th class="price-unit">#{l(:field_invoice_line_price)}</th>
          <th class="price">#{l(:field_invoice_line_total)}</th>
        </tr>
      </thead>
      <tbody id="items-body">
        {% for item in invoice.lines %}
        <tr class="item-row" id="row_{{ item.id}}">
          <td class="position">{{ item.position }}</td>
          <td class="description">{{ item.description | multi_line }}</td>
          <td class="quantity">x{{ item.quantity | numeric: 4 }}</td>
          <td class="price-unit">{{ item.price | currency }}</td>
          <td class="price">{{ item.total | currency }}</td>
        </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
  <div class="section">
    <div id="totals" class="right">
      <table>
        <tbody>
           {% if invoice.has_taxes? %}
          <tr>
            <td class="label" id="subtotal-label">#{l(:label_invoice_sub_amount)}</td>
            <td class="value right-align" id="subtotal">{{ invoice.subtotal | currency }}</td>
          </tr>
          {% endif %}
          {% if invoice.discount > 0 %}
          <tr>
            <td class="label" id="subtotal-label">
              #{l(:field_invoice_discount)}
              {% if invoice.discount_type == 0 %}
                ({{invoice.discount_rate | round: 2 }}%)
              {% endif %}
            </td>
            <td class="value right-align" id="subtotal">-{{ invoice.discount | currency }}</td>
          </tr>
          {% endif %}

          {% if invoice.has_taxes? %}
          {% for tax_group in invoice.tax_groups %}
          <tr>
            <td id="tax-value-label" class="label">
              <span id="tax-text">#{l(:label_invoice_tax)}</span>
              <span id="tax-percent-value">{{tax_group[0]}}%</span>
            </td>
            <td class="value right-align" id="tax-value">{{tax_group[1]  | round: 2 | currency}}</td>
          </tr>
          {% endfor %}
          {% endif %}
          <tr style="display:none">
            <td id="tax2-value-label" class="label">
              <span id="tax2-text"></span>
              <span id="tax-percent-value">0</span>
            </td>
            <td class="value right-align" id="tax2-value"></td>
          </tr>
          <tr class="highlighted">
            <td id="total-label" class="label">#{l(:label_invoice_amount_due)}</td>
            <td class="value right-align" id="total">{{ invoice.amount | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  <div class="section">
    <div id="payment_details">
       <div id="customer" class="title"></div>
       {{account.bill_info | textile | multi_line}}
    </div>
    <div id="footer" class="clear">
      {{ invoice.description | textile }}
    </div>
  </div>

</div>


  
<style>
#{style}
</style>
HTML

          content
        end
      end
    end
  end
end
