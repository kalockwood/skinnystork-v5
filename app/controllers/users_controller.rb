class UsersController < ApplicationController
  before_filter :authenticate_user!#Verifies that the user is logged in

  def index #Manages the logic for /users (the pseudo admin)
    authorize! :index, @user, :message => 'Not authorized as an administrator.' #Only Admin have access
    @users = User.all #Stores all users on a variable
  end

  def show
    @user = User.find(params[:id]) #Store a specific user by id on a variable
  end
  
 def update #Method contains logic for updating users under /users
    authorize! :update, @user, :message => 'Not authorized as an administrator.' #Only Admins have access
    @user = User.find(params[:id]) #store specified user on a variable
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil? #Gets the id of the role of the current user, with verification that his role is not nil
    params[:user] = params[:user].except(:role_ids) #takes all the params of the user except the role
    if @user.update_attributes(params[:user]) 
      @user.update_plan(role) unless role.nil? #Logic for changing role of a user
      redirect_to users_path, :notice => "User updated." #Refresh page 
    else
      redirect_to users_path, :alert => "Unable to update user." #Alert error message
    end
  end
  
  
  def destroy#This destroy method is for the admin to actually destroy the user completely. 
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.' #Only Admins have access
    user = User.find(params[:id]) #store specified user on a variable
    unless user == current_user #Checks that the admin is not trying to delete himself
      user.destroy #destroys the user permanently from db
      redirect_to users_path, :notice => "User deleted." #Refreshes page and send success alert
    else
      redirect_to users_path, :notice => "Can't delete yourself." # Sends error alert
    end
  end

private
	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end 

  #def role_params
   # params.require(:user_role).permit(:role_id)
  #end
end
