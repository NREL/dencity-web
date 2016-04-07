# CanCan ability class
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
    # admin
    if user.has_role? :admin
      # an admin can do everything
      can :manage, :all
    # editor
    elsif user.has_role? :editor
      can :manage, [Meta, Unit]
      can [:read, :create, :update], Structure
    # authenticated user
    elsif user.encrypted_password
      can [:read, :create], [Meta, Structure]
      can :manage, Structure, user_id: user.id
      can :manage, Analysis, user_id: user.id
      can :manage, MeasureInstance, user_id: user.id
      can [:read, :update], User, id: user.id
      can :read, Unit
      # API actions (authenticated users can post analysis and structures.  Anyone can search)
      can :analysis, :api
      can :structure, :api
      can :related_file, :api
      can :meta_batch_upload, :api
      can :meta_upload, :api
      can :remove_file, :api
    # unauthenticated
    else
      can :read, [Meta, Unit, Structure, Analysis, MeasureDescription, MeasureInstance]
      can [:meta_upload, :meta_batch_upload], Meta
      can :retrieve_analysis, :api
      can :search, :api
      can :search_by_arguments, :api
    end
  end
end
