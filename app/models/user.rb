class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :assign_default_role

  def assign_default_role
    add_role(:trailing)
  end

  def update_plan(role) #Method for updating plan on settings page, takes a role as a parameter
      self.role_ids = [] #Sets the user roles to a blank array to avoid double roles
      self.add_role(role.name) #Adds the role received as parameter to the array
     
  end

end
