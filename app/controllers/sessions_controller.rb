class SessionsController < Devise::SessionsController

# DELETE /resource/sign_out
  def destroy
    logger.info "YES YES YES YES YES YES YES YES YES YES YES YES "
    profile = Profile.where(:user_id => current_user.id).take
    profile.profile_status = "Offline"

    if profile.save
      #TODO Check which is more economical, checking id or checking statuses
      my_transactions_as_lender = Transaction.where(:lender_id => current_user.id).where.not(:status => "Rejected").where.not(:status => "Cancelled").where.not(:status => "Complete")
      my_transactions_as_borrower = Transaction.where(:borrower_id => current_user.id).where.not(:status => "Rejected").where.not(:status => "Cancelled").where.not(:status => "Complete")

      if !my_transactions_as_lender.nil?
        my_transactions_as_lender.each do |tl|
          update_lender_offline = Array.new
          update_lender_offline << "offline"
          update_lender_offline << {
          :id => tl.id
          }
          publish_channel_all_borrowers = "transaction_listener_" + tl.borrower_id.to_s
          Firebase.push(publish_channel_all_borrowers, update_lender_offline.to_json)
        end
      end

      if !my_transactions_as_borrower.nil?
        my_transactions_as_borrower.each do |tl|
          update_borrower_offline = Array.new
          update_borrower_offline << "offline"
          update_borrower_offline << {
          :id => tl.id
          }
          publish_channel_all_lenders = "transaction_listener_" + tl.lender_id.to_s
          Firebase.push(publish_channel_all_lenders, update_borrower_offline.to_json)
        end
      end
    end

    super
  end
end