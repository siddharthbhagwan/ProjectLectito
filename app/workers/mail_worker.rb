class MailWorker
include Sidekiq::Worker

	def perform_borrow_request(lender_id)
		AppMailer.request_to_borrow_notification(lender_id).deliver
	end

	def perform_borrow_accept(borrower_id)
		AppMailer.accept_request_to_borrow_notification(borrower_id).deliver
	end

end