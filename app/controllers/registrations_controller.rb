#********************************************************
#This file is overriding devise registrations controller
#********************************************************
class RegistrationsController < Devise::RegistrationsController

  def new #When a user is created, unless he is an admin, a role(subcription/plan) must be chosen. For the time being this is not being used, since we are forcing all users to be bold_moves at the begining
    @plan = params[:plan]
    if @plan && ENV["ROLES"].include?(@plan) && @plan != "admin"
      super
    else
      redirect_to root_path, :notice => 'Please select a subscription plan below.'
    end
  end

  def update_plan #Defines the logic behind the Change plan form on the Settings page
    @user = current_user #Stores the current user on a variable
    role_id = params[:user][:role_ids] unless params[:user].nil? || params[:user][:role_ids].nil? #Gets the id of the role of the current user, with verification that his role is not nil
    role = Role.find_by_id role_id unless role_id.nil? #Stores the role that matches the id fetched previously on a variable
    authorized = !role.nil? && (role.name != 'admin' || current_user.roles.first.name == 'admin')
    if authorized && @user.update_plan(role) #checks that the user is authorized to change his plan and that it was updated on the db
      redirect_to edit_user_registration_path #refreshes page
    else
      flash.alert = 'Unable to update plan.' #Gives an error alert
      render :edit #renders the form again
    end
  end

  def destroy #This method defines the cancellation logic, doesn't actually erase the user
    unless resource.customer_id.nil? #Checks that the user has a Stripe customer_id
      customer = Stripe::Customer.retrieve(resource.customer_id) #Fetches all the data from Stripe form the customer with that id and stores it in a variable
      unless customer.nil? or customer.respond_to?('deleted') #Checks that the customer still exists on Stripe or that it hasn't been deleted
        subscription = customer.subscriptions.data[0] #Gets the current subscription (stripe) of the customer
        if (subscription.status == 'active' or customer.subscription.status == 'trialing') #Checks that the status of the subscription is either active or trialing
          UserMailer.expire_email(resource).deliver  #Sends the user and the admins a mail of cancellation
          customer.cancel_subscription(at_period_end: true) #Sets the subscription to cancel from stripe when the billing period ends
        end
      end
    end
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name) #Signs the user out of the application
    set_flash_message :notice, :destroyed if is_navigational_format? 
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end


  protected

    def after_update_path_for(resource)
      edit_user_registration_path(resource) #Sets the page to refresh when the fields in the settings page are updated
    end

  private
  def build_resource(*args)
    super
    if params[:plan]
      resource.add_role(params[:plan])
    end
  end
end
