class AttachmentsController < ApplicationController
  # before_action :set_ticket
  # before_action :set_attachment, only: [:show]

  def show
    attachment = Attachment.find(params[:id])
    authorize attachment, :show?
    send_file attachment.file.path, disposition: :inline
  end

  # private 

  # def set_ticket
  #   @ticket = Ticket.find(params[:id])
  # end

  # def set_attachment
  #   @attachment = @tickets.attachments.find(params[:id])
  # end
end
