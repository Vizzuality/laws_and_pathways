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

  PUBLISHABLE_RESOURCES = [
    Company, Geography, Legislation, Litigation, Target
  ].freeze

  def initialize(user)
    alias_action :read, :create, :update, :destroy, to: :crud
    alias_action :read, :update, to: :modify

    @user = user

    can :read, :all

    send(@user.role.to_sym) if @user.present?

    can :modify, AdminUser, id: user.id
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

  def publishable_resources_within(resources)
    resources & PUBLISHABLE_RESOURCES
  end

  private

  def editor_abilities_for(resources)
    resources.each do |resource|
      can :create, resource
      can :update, resource # TODO: creating works fine, but there are no 'edit' links (they should be visible)
    end

    publishable_resources_within(resources).each do |resource|
      # TODO
      # - archiving doesn't work now for some reason (no error in UI)
      # - archiving is only available via bulk action now (no publication sidebar)
      #   should be probably added to actions menu
      can :archive, resource
    end
  end

  def publisher_abilities_for(resources)
    resources.each { |resource| can :crud, resource }

    can :manage, Tag
    can :create, AdminUser # TODO: add restriction of what user roles can publisher add

    publishable_resources_within(resources).each do |resource|
      can :archive, resource
      can :publish, resource
    end
  end
end
