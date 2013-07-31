class AppMailer < ActionMailer::Base
  default from: "ProjectLectito@example.com"

  def request_to_borrow_notification(lender_id)
    @user = User.find(lender_id)
    mail(to: @user.email, subject: 'You have a new borrow request')
  end

  def accept_request_to_borrow_notification(borrower_id)
  	@user = User.find(borrower_id)
    mail(to: @user.email, subject: 'Request to borrow accepted')
  end

end
