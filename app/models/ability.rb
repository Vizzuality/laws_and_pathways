# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user

    if @user
      send(@user.role.to_sym)
    else # guest
      can :read, :all
    end
  end

  def super_user
    can :read, :all
    can :manage, :all
  end

  def editor_tpi
    can :read, :all
    can :manage, :all
  end

  def editor_laws
    can :read, :all
    can :manage, :all
  end

  def publisher_tpi
    can :read, :all
    can :manage, :all
  end

  def publisher_laws
    can :read, :all
    can :manage, :all
  end
end
