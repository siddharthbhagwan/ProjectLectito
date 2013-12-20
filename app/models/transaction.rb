class Transaction < ActiveRecord::Base
	#FIXME check for security of ids => primary key for users	
  attr_accessible :borrower_id, :lender_id, :status, :inventory_id

  validates :borrower_id, :lender_id, :status, :inventory_id , :presence => true

  has_many :chats
  belongs_to :borrower, class_name: "User"
  belongs_to :lender, class_name: "User"

  #scope :pending, -> { where(:status => :Pending) }
  def update_transaction(action, current_user, *transaction_data)
  	#TODO Modify and clauses after delivery kicks in
		case action

			when "Accepted"
				if (is_my_transaction(current_user)) and (self.status == "Pending")
					self.status = "Accepted"
					self.acceptance_date = DateTime.now.to_time
					if (!transaction_data[0].blank? and !transaction_data[1].blank?)
						self.accept_pickup_date = transaction_data[0] + ", " + transaction_data[1]
					end

					inventory_rented_out = Inventory.find(self.inventory_id)
					inventory_rented_out.status = "Rented Out"
					inventory_rented_out.save

					if self.save
						true
					else
						false
					end
				else
					false
				end

			when 'Received Borrower'
				if (is_my_transaction(current_user)) and (self.status == "Accepted")
					self.received_date = DateTime.now.to_time
					self.status = "Received Borrower"
					#self.returned_date = @borrower_received_transaction.received_date + 14.days

					if self.save
						true
					else
						false
					end

				else
					false
				end

			when 'Reject'
				if (is_my_transaction(current_user)) and (self.status == "Pending")
					self.status = "Rejected"
					self.rejection_date = DateTime.now.to_time
					self.rejection_reason = transaction_data[0]

					if self.save
						true
					else
						false
					end
				else
					false
				end

			when 'Cancel'
				if (is_my_transaction(current_user)) and (self.status == "Pending")
					self.status = "Cancelled"

					if self.save
						true
					else
						false
					end
				else
					false
				end

			when 'Returned'
				if (is_my_transaction(current_user)) and (self.status = "Received Borrower")
					self.status = "Returned"
					self.returned_date = DateTime.now.to_time
					self.borrower_feedback = transaction_data[0] #borrower_feedback
					self.borrower_comments = transaction_data[1] #borrower_comments
					if (!transaction_data[2].blank? and !transaction_data[3].blank?) #return_Date, #return_time
						self.return_pickup_date = transaction_data[2] + ", " + transaction_data[3]
					end

					if self.save
						true
					else
						false
					end
				else
					false
				end						

			when 'Complete'
				if (is_my_transaction(current_user)) and (self.status == "Returned")
					current_DateTime = DateTime.now.to_time
					self.return_received_date = current_DateTime
					self.lender_feedback = transaction_data[0] 
					self.lender_comments = transaction_data[1]

					if self.return_pickup_date.nil?
						self.borrow_duration = ((current_DateTime - self.received_date)/1.days).round
					else
						self.borrow_duration = ((current_DateTime - self.return_pickup_date)/1.days).round
					end

					received_inventory = Inventory.where(:id => self.inventory_id).take
					received_inventory.status = "Available"
					received_inventory.save

					self.status = "Complete"

					if self.save
						true
					else
						false
					end
				else
					false
				end

		end
	end

	# Fn that takes a transaction id and returns true or false depending on wether the current suer is a part of that transaction or not
	def is_my_transaction(current_user)
    if (self.lender_id == current_user) or (self.borrower_id == current_user)
      return true
    else
    	return false
    end

  rescue ActiveRecord::RecordNotFound
		return false
  end

end