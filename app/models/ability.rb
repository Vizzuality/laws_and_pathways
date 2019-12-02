# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user

    if @user.present?
      send(@user.role.to_sym)
    else # guest
      can :read, :all
    end
  end

  # SuperUser: can manage all pieces of content, including users;
  def super_user
    can :manage, :all
    can :read, :all
  end

  # EditorTPI:
  #     can add new content to their area;
  #     can't publish or unpublish any pieces of content;
  #     can edit any content on their area (even if it's published);
  #     can view all the content on the site;
  #     can archive any content;
  #     can't delete content;
  def editor_tpi
    can :edit, Company
    can :read, Company
    can :create, Company
    can :update, Company
  end

  # EditorLaws:
  #     can add new content to their area;
  #     can't publish or unpublish any pieces of content;
  #     can edit any content on their area (even if it's published);
  #     can view all the content on the site;
  #     can archive any content;
  #     can't delete content;
  def editor_laws
    can :read, :all
    can :manage, :all
  end

  # PublisherTPI:
  #     Can manage all pieces of content related to their area "TPI" or "Laws" table.
  #     Can manage tags;
  #     Can add new Publishers or Editors to their area.
  #     Can publish all content types on their area;
  #     Can archive any content;
  #     Can delete all content;
  def publisher_tpi
    can :publish, :all
    can :read, :all
    can :manage, :all
  end

  # PublisherLaws:
  #     Can manage all pieces of content related to their area "TPI" or "Laws" table.
  #     Can manage tags;
  #     Can add new Publishers or Editors to their area.
  #     Can publish all content types on their area;
  #     Can archive any content;
  #     Can delete all content;
  def publisher_laws
    can :read, :all
    can :manage, :all
  end
end
