# frozen_string_literal: true

##
# Create event allows the printing of barcodes
class BarcodeLabelsController < ApplicationController
  include BarcodePrinting

  before_action :find_printer
  before_action :generate_labels

  def create
    BarcodeSheet.new(@printer, @labels).print!
    render(
      json: { 'success' => 'Your barcodes have been printed' }
    )
  rescue BarcodeSheet::PrintError => exception
    Rails.logger.error(exception.message)
    render(
      json: { 'error' => "There was a problem printing your barcodes. #{exception.message}" }
    )
  rescue Errno::ECONNREFUSED
    render(
      json: { 'error' => 'Could not connect to the barcode printing service.' }
    )
  end

  private

  def generate_labels
    @labels = (params[:numbers] || []).map do |_, number|
      BarcodeSheet::Label.new(
        prefix: params[:prefix],
        number: number,
        study: params[:study]
      )
    end
  end
end
