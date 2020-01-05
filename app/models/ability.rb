# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # Workaround for checking abilities on Draper decorators
  # See https://github.com/activeadmin/activeadmin/issues/5443
  prepend Draper::CanCanCan

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

    @user = user

    can :read, :all

    return unless @user.present?

    send(@user.role.to_sym)

    can :update, AdminUser, id: user.id
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
      can :update, resource
    end

    publishable_resources_within(resources).each do |resource|
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
