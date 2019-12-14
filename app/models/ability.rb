# frozen_string_literal: true

class Ability
  include CanCan::Ability

  TPI_RESOURCES = [
    Company, MQ::Assessment, CP::Assessment, TPISector, TPIPage,
    NewsArticle, Testimonial, Publication
  ].freeze
  LAWS_RESOURCES = [
    Legislation, Litigation, Target, ExternalLegislation, LawsSector,
    CCLOWPage, Instrument, InstrumentType, Governance, GovernanceType
  ].freeze

  PUBLISHABLE_RESOURCES = [Company, Geography, Legislation, Litigation, Target].freeze

  def initialize(user)
    @user = user

    can :read, :all

    send(@user.role.to_sym) if @user.present?
  end

  def super_user
    can :manage, :all
  end

  def editor_tpi
    editor_abilities_for TPI_RESOURCES
  end

  def editor_laws
    editor_abilities_for LAWS_RESOURCES
  end

  def publisher_tpi
    publisher_abilities_for TPI_RESOURCES
  end

  def publisher_laws
    publisher_abilities_for LAWS_RESOURCES
  end

  private

  def editor_abilities_for(resources)
    # Can add/edit new content to their area (Laws/TPI)
    resources.each do |resource|
      can :create, resource
      can :update, resource
    end

    # Can archive any content from their area
    (resources & PUBLISHABLE_RESOURCES).each do |resource|
      can :archive, resource
    end
  end

  def publisher_abilities_for(resources)
    # Can manage all pieces of content related to their area (Laws/TPI)
    resources.each { |resource| can :manage, resource }

    # Can manage tags
    can :manage, Tag

    # Can add new Publishers or Editors to their area
    can :create, AdminUser

    # Can publish all content types from their area
    (resources & PUBLISHABLE_RESOURCES).each do |resource|
      can :publish, resource
      can :archive, resource
    end
  end
end
