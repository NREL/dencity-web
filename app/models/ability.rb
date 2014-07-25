class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Define abilities for the passed in user here.
    user ||= User.new # guest user (not logged in)
                        # a signed-in user can do everything
    if user.has_role? :admin
      # an admin can do everything
      can :manage, :all
    elsif user.has_role? :editor
      # an editor can do everything to documents and reports
      can :manage, [Meta, Unit]
      # but can only read, create and update charts (ie they cannot
      # be destroyed or have any other actions from the charts_controller.rb
      # executed)
      can [:read, :create, :update], Structure
      # an editor can only view the annual report
      can :read, AnnualReport
    elsif user.encrypted_password
      can [:read, :create], [Meta, Structure]
      can :manage, Structure, :user_id => user.id
      can :manage, Provenance, :user_id => user.id
      can :manage, Attachment, :user_id => user.id
      can :manage, MeasureInstance, :user_id => user.id
      can :read, Unit
    else
      can :read, [Meta, Unit]
    end

  end
end
